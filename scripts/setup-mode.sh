#!/usr/bin/env bash
# Thin compatibility wrapper for transactional methodology configuration.

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$PLUGIN_ROOT/scripts/claude-obsidian.py"
VAULT=""
MODE=""
APPLY=false
CHECK=false
GENERATED_AT=""
APPROVED_PLAN_SHA256=""

usage() {
  cat <<'EOF'
Uso: scripts/setup-mode.sh [--vault PATH] [--mode MODE] [--check] [--apply]
                       [--generated-at ISO-UTC]
                       [--approved-plan-sha256 SHA256]

MODE es generic, lyt, para o zettelkasten. Sin --apply, establecer un modo
imprime una simulación completa de la transacción. Sin --mode, se muestra la
configuración actual. Este comando nunca mueve notas existentes ni crea
carpetas iniciales de forma implícita.
Fija --generated-at para la vista previa y luego repite exactamente ese valor
con el --approved-plan-sha256 revisado al aplicar el plan.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --vault)
      [ "$#" -ge 2 ] || { echo "ERROR: --vault requiere una ruta" >&2; exit 2; }
      VAULT="$2"
      shift
      ;;
    --mode)
      [ "$#" -ge 2 ] || { echo "ERROR: --mode requiere un valor" >&2; exit 2; }
      MODE="$2"
      shift
      ;;
    --check) CHECK=true ;;
    --apply) APPLY=true ;;
    --approved-plan-sha256)
      [ "$#" -ge 2 ] || { echo "ERROR: --approved-plan-sha256 requiere un valor" >&2; exit 2; }
      APPROVED_PLAN_SHA256="$2"
      shift
      ;;
    --generated-at)
      [ "$#" -ge 2 ] || { echo "ERROR: --generated-at requiere un valor" >&2; exit 2; }
      GENERATED_AT="$2"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: argumento desconocido: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if $CHECK || [ -z "$MODE" ]; then
  if [ -n "$VAULT" ]; then
    exec python3 "$CLI" mode get --vault "$VAULT"
  fi
  exec python3 "$CLI" mode get
fi

case "$MODE" in
  generic|lyt|para|zettelkasten) ;;
  *) echo "ERROR: modo no válido: $MODE" >&2; exit 2 ;;
esac

arguments=(mode set "$MODE")
[ -n "$VAULT" ] && arguments+=(--vault "$VAULT")
$APPLY && arguments+=(--apply)
[ -n "$APPROVED_PLAN_SHA256" ] && arguments+=(--approved-plan-sha256 "$APPROVED_PLAN_SHA256")
[ -n "$GENERATED_AT" ] && arguments+=(--generated-at "$GENERATED_AT")
exec python3 "$CLI" "${arguments[@]}"
