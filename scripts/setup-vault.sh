#!/usr/bin/env bash
# Capa ligera de compatibilidad del flujo portátil de bóvedas de claude-obsidian.
#
# Esta capa nunca crea, reemplaza ni elimina contenido de la bóveda por sí
# sola. Traduce las opciones heredadas de setup-vault a la CLI canónica de
# Python, donde residen la planificación en simulación, la aprobación exacta
# del plan y las transacciones recuperables.
#
# Uso:
#   bash scripts/setup-vault.sh [--dry-run] [--init|--adopt] [--vault PATH|PATH]
#   bash scripts/setup-vault.sh --check [--vault PATH|PATH]
#   bash scripts/setup-vault.sh --apply --approved-plan-sha256 HASH \
#     --generated-at ISO-UTC --operation-id ID [--init|--adopt] [--vault PATH|PATH]
#   bash scripts/setup-vault.sh --dry-run --force --adopt [--vault PATH|PATH]
#
# Compatibilidad:
#   - la vista previa es el modo por defecto;
#   - si el destino no existe, se elige init; si es un directorio existente, se
#     elige adopt, salvo que se indique --init o --adopt de forma explícita;
#   - --force sin un modo explícito conserva el significado heredado de apply;
#   - sin ruta, se sigue usando el directorio de trabajo actual de quien llama.

set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

MODE="preview"
MODE_EXPLICIT=false
ACTION="auto"
ACTION_EXPLICIT=false
FORCE=false
VAULT_INPUT=""
POSITIONAL_VAULT=""
APPROVED_PLAN_SHA256=""
GENERATED_AT=""
OPERATION_ID=""

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

fail_usage() {
  echo "ERR: $*" >&2
  usage >&2
  exit 2
}

set_mode() {
  local requested="$1"
  if $MODE_EXPLICIT && [ "$MODE" != "$requested" ]; then
    fail_usage "elige exactamente una de --check, --dry-run o --apply"
  fi
  MODE="$requested"
  MODE_EXPLICIT=true
}

set_action() {
  local requested="$1"
  if $ACTION_EXPLICIT && [ "$ACTION" != "$requested" ]; then
    fail_usage "elige exactamente una de --init o --adopt"
  fi
  ACTION="$requested"
  ACTION_EXPLICIT=true
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      set_mode "check"
      ;;
    --dry-run)
      set_mode "preview"
      ;;
    --apply)
      set_mode "apply"
      ;;
    --init)
      set_action "init"
      ;;
    --adopt)
      set_action "adopt"
      ;;
    --force)
      FORCE=true
      if ! $MODE_EXPLICIT; then
        MODE="apply"
      fi
      ;;
    --approved-plan-sha256)
      [ "$#" -ge 2 ] || fail_usage "--approved-plan-sha256 requiere un valor"
      [ -z "$APPROVED_PLAN_SHA256" ] || fail_usage \
        "--approved-plan-sha256 solo puede indicarse una vez"
      APPROVED_PLAN_SHA256="$2"
      shift
      ;;
    --generated-at)
      [ "$#" -ge 2 ] || fail_usage "--generated-at requiere un valor"
      [ -z "$GENERATED_AT" ] || fail_usage "--generated-at solo puede indicarse una vez"
      GENERATED_AT="$2"
      shift
      ;;
    --operation-id)
      [ "$#" -ge 2 ] || fail_usage "--operation-id requiere un valor"
      [ -z "$OPERATION_ID" ] || fail_usage "--operation-id solo puede indicarse una vez"
      OPERATION_ID="$2"
      shift
      ;;
    --vault)
      [ "$#" -ge 2 ] || fail_usage "--vault requiere una ruta"
      [ -z "$VAULT_INPUT" ] || fail_usage "--vault solo puede indicarse una vez"
      VAULT_INPUT="$2"
      shift
      ;;
    --vault=*)
      [ -z "$VAULT_INPUT" ] || fail_usage "--vault solo puede indicarse una vez"
      VAULT_INPUT="${1#--vault=}"
      [ -n "$VAULT_INPUT" ] || fail_usage "--vault requiere una ruta"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      [ "$#" -le 1 ] || fail_usage "solo se acepta una ruta posicional de bóveda"
      if [ "$#" -eq 1 ]; then
        POSITIONAL_VAULT="$1"
      fi
      break
      ;;
    -*)
      fail_usage "opción desconocida: $1"
      ;;
    *)
      [ -z "$POSITIONAL_VAULT" ] || fail_usage \
        "solo se acepta una ruta posicional de bóveda"
      POSITIONAL_VAULT="$1"
      ;;
  esac
  shift
done

if [ -n "$VAULT_INPUT" ] && [ -n "$POSITIONAL_VAULT" ]; then
  fail_usage "usa --vault o una ruta posicional de bóveda, no ambas"
fi

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="$PLUGIN_ROOT/scripts/claude-obsidian.py"
VAULT="${VAULT_INPUT:-${POSITIONAL_VAULT:-$PWD}}"

if [ "$MODE" = "check" ]; then
  $ACTION_EXPLICIT && fail_usage "--check no se puede combinar con --init ni con --adopt"
  $FORCE && fail_usage "--check no se puede combinar con --force"
  [ -z "$APPROVED_PLAN_SHA256" ] || fail_usage \
    "--check no se puede combinar con --approved-plan-sha256"
  [ -z "$GENERATED_AT" ] || fail_usage "--check no se puede combinar con --generated-at"
  [ -z "$OPERATION_ID" ] || fail_usage "--check no se puede combinar con --operation-id"
  exec python3 "$CORE" doctor --vault "$VAULT"
fi

if [ "$ACTION" = "auto" ]; then
  if [ -d "$VAULT" ]; then
    ACTION="adopt"
  else
    ACTION="init"
  fi
fi

COMMAND=(python3 "$CORE" "$ACTION" "$VAULT")
$FORCE && COMMAND+=(--force)
[ -z "$GENERATED_AT" ] || COMMAND+=(--generated-at "$GENERATED_AT")
[ -z "$OPERATION_ID" ] || COMMAND+=(--operation-id "$OPERATION_ID")

case "$MODE" in
  preview)
    [ -z "$APPROVED_PLAN_SHA256" ] || fail_usage \
      "--approved-plan-sha256 solo se acepta con --apply"
    ;;
  apply)
    [ -n "$APPROVED_PLAN_SHA256" ] || fail_usage \
      "--apply requiere --approved-plan-sha256 de la simulación revisada"
    COMMAND+=(--approved-plan-sha256 "$APPROVED_PLAN_SHA256" --apply)
    ;;
  *)
    fail_usage "modo de configuración no admitido: $MODE"
    ;;
esac

exec "${COMMAND[@]}"
