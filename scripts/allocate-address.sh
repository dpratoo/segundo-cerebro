#!/usr/bin/env bash
# Diagnóstico de compatibilidad, de solo lectura, para el asignador de
# direcciones heredado.
#
# La reserva de direcciones ahora corresponde exclusivamente a una operación
# claude-obsidian.transaction.v1 revisada y con address_requests. Esta utilidad
# solo imprime el siguiente valor observado del contador y nunca crea bloqueos,
# contadores, directorios ni archivos.
#
# Uso:
#   scripts/allocate-address.sh [--vault PATH] [--peek]
#
# Los modos heredados `allocate` y `--rebuild` se rechazan e indican cómo migrar.

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPLICIT_VAULT=""
MODE="peek"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --vault)
      [ "$#" -ge 2 ] || { echo "ERR: --vault requiere una ruta" >&2; exit 2; }
      EXPLICIT_VAULT="$2"
      shift
      ;;
    --vault=*) EXPLICIT_VAULT="${1#--vault=}" ;;
    --peek) MODE="peek" ;;
    allocate|--rebuild) MODE="disabled" ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "ERR: argumento desconocido: $1" >&2; exit 2 ;;
  esac
  shift
done

if [ "$MODE" = "disabled" ]; then
  echo "ERR LEGACY_ALLOCATOR_READ_ONLY: reserva las direcciones con address_requests en un único paquete de transacción revisado; la asignación/reconstrucción directa está desactivada" >&2
  exit 2
fi

PYTHONPATH="$PLUGIN_ROOT${PYTHONPATH:+:$PYTHONPATH}" python3 - "$EXPLICIT_VAULT" "$PLUGIN_ROOT" <<'PY'
import re
import sys
from pathlib import Path

from claude_obsidian.paths import VaultSelectionError, resolve_vault_root
from claude_obsidian.transaction import TransactionError, read_vault_regular

explicit = sys.argv[1] or None
plugin_root = Path(sys.argv[2])
try:
    root = resolve_vault_root(
        explicit, start=Path.cwd(), plugin_root=plugin_root
    ).root
    raw = read_vault_regular(
        root, ".vault-meta/address-counter.txt", limit=64 * 1024
    )
except (VaultSelectionError, TransactionError) as exc:
    print(f"ERR {exc.code}: {exc}", file=sys.stderr)
    raise SystemExit(2)

if raw is not None:
    try:
        value = raw.decode("ascii").strip()
    except UnicodeDecodeError:
        value = ""
    if not value.isdigit() or not 1 <= int(value) <= 999999:
        print("ERR INVALID_ADDRESS_COUNTER: el contador debe contener 1..999999", file=sys.stderr)
        raise SystemExit(3)
    print(int(value))
    raise SystemExit(0)

highest = 0
wiki = root / "wiki"
if wiki.is_dir() and not wiki.is_symlink():
    for page in sorted(wiki.rglob("*.md")):
        if page.is_symlink() or not page.is_file():
            continue
        try:
            page.resolve(strict=True).relative_to(wiki.resolve(strict=True))
            text = page.read_text(encoding="utf-8", errors="replace")
        except (OSError, ValueError):
            continue
        lines = text.splitlines()
        if not lines or lines[0].strip() != "---":
            continue
        for line in lines[1:]:
            if line.strip() == "---":
                break
            match = re.fullmatch(r"address:\s*c-([0-9]{6})\s*", line)
            if match:
                highest = max(highest, int(match.group(1)))
print(highest + 1)
PY
