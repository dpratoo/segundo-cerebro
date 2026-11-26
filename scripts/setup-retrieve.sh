#!/usr/bin/env bash
# Safe, vault-scoped bootstrap for the optional retrieval cache.

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT_INPUT=""
APPLY=false
CHECK=false
NO_LLM=false
ALLOW_EGRESS=false
REBUILD=false
ALLOW_REMOTE_OLLAMA=false

usage() {
  cat <<'EOF'
Uso: scripts/setup-retrieve.sh [--vault PATH] [--check] [--apply]
     [--no-llm|--allow-egress] [--rebuild] [--allow-remote-ollama]

Por defecto hace una vista previa de solo lectura de los prefijos sintéticos.
--apply construye los fragmentos y el estado BM25 acotados a la bóveda. Enviar
texto de las páginas a un modelo requiere la opción explícita --allow-egress.
Usar Ollama remoto requiere --allow-remote-ollama.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --vault)
      [ "$#" -ge 2 ] || { echo "ERROR: --vault requiere una ruta" >&2; exit 2; }
      VAULT_INPUT="$2"
      shift
      ;;
    --check) CHECK=true ;;
    --apply) APPLY=true ;;
    --no-llm) NO_LLM=true ;;
    --allow-egress) ALLOW_EGRESS=true ;;
    --rebuild) REBUILD=true ;;
    --allow-remote-ollama) ALLOW_REMOTE_OLLAMA=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: argumento desconocido: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if $NO_LLM && $ALLOW_EGRESS; then
  echo "ERROR: --no-llm y --allow-egress son mutuamente excluyentes" >&2
  exit 2
fi

for helper in contextual-prefix.py bm25-index.py rerank.py retrieve.py; do
  [ -f "$PLUGIN_ROOT/scripts/$helper" ] || {
    echo "ERROR: falta un script auxiliar del producto: scripts/$helper" >&2
    exit 3
  }
done

set +e
VAULT="$(PYTHONPATH="$PLUGIN_ROOT${PYTHONPATH:+:$PYTHONPATH}" python3 - "$VAULT_INPUT" "$PLUGIN_ROOT" <<'PY'
import sys
from pathlib import Path
from claude_obsidian.paths import VaultSelectionError, resolve_vault_root

explicit = sys.argv[1] or None
try:
    selection = resolve_vault_root(
        explicit,
        start=Path.cwd(),
        plugin_root=Path(sys.argv[2]),
    )
except VaultSelectionError as exc:
    print(f"ERR {exc.code}: {exc}", file=sys.stderr)
    raise SystemExit(2)
print(selection.root)
PY
)"
resolve_status=$?
set -e
[ "$resolve_status" -eq 0 ] || exit "$resolve_status"

echo "Bóveda: $VAULT"
echo "Scripts auxiliares del producto: $PLUGIN_ROOT/scripts"

if $CHECK; then
  python3 "$PLUGIN_ROOT/scripts/bm25-index.py" --vault "$VAULT" stats 2>/dev/null || {
    echo "READY: los scripts auxiliares de recuperación están instalados; el índice de la bóveda aún no está construido."
  }
  exit 0
fi

prefix_args=(--vault "$VAULT" --all)
$NO_LLM && prefix_args+=(--no-llm)
$ALLOW_EGRESS && prefix_args+=(--allow-egress)
$REBUILD && prefix_args+=(--rebuild)

if ! $APPLY; then
  python3 "$PLUGIN_ROOT/scripts/contextual-prefix.py" "${prefix_args[@]}" --peek
  echo "Solo simulación. Repite con --apply para escribir el estado de recuperación derivado."
  exit 0
fi

python3 "$PLUGIN_ROOT/scripts/contextual-prefix.py" "${prefix_args[@]}"
python3 "$PLUGIN_ROOT/scripts/bm25-index.py" --vault "$VAULT" build

retrieve_args=(--vault "$VAULT" "wiki" --top 1 --no-rerank)
$ALLOW_REMOTE_OLLAMA && retrieve_args+=(--allow-remote-ollama)
python3 "$PLUGIN_ROOT/scripts/retrieve.py" "${retrieve_args[@]}" >/dev/null
echo "Estado de recuperación construido correctamente."
