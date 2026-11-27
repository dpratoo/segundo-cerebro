# Modos de instalación admitidos

Resuelve la raíz del producto instalado a partir de la ubicación de la skill que
lo invoca, no del directorio de trabajo de la bóveda del usuario:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

## Plugin del marketplace de Claude

Instala el plugin a través de su marketplace e invoca las skills con espacio de
nombres, como `/claude-obsidian:wiki`. Los recursos del plugin viven en una
caché efímera. El estado modificable de la bóveda debe resolverse a partir del
proyecto, de `--vault` o de la configuración del espacio de trabajo, nunca de
`${CLAUDE_PLUGIN_ROOT}`.

## Desarrollo local de plugins de Claude

```bash
claude --plugin-dir /path/to/claude-obsidian
```

Las skills siguen teniendo espacio de nombres. Ejecuta Claude desde la bóveda del
usuario, no desde el directorio de código fuente del plugin, o configura la
bóveda de forma explícita.

## Agent Skills portátiles

Usa `scripts/setup-multi-agent.sh` o enlaza cada directorio `skills/<name>/` en
la ruta de descubrimiento directa del host, `<skill-root>/<name>/SKILL.md`.
Codex, OpenCode y otros hosts de Agent Skills consumen los mismos archivos
`SKILL.md`. Los hooks exclusivos de Claude son adaptadores, no lógica central
del flujo de trabajo.

## Clon del producto

Un clon del código fuente es código del producto y de desarrollo, no un plugin
instalado de forma automática ni la bóveda de usuario recomendada. Crea una
bóveda separada:

```bash
python3 "$CORE" init /path/to/vault \
  --generated-at <ISO-UTC> --operation-id init-reviewed
python3 "$CORE" init /path/to/vault \
  --generated-at <ISO-UTC> --operation-id init-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

Adopta una bóveda de Obsidian existente sin destruir nada:

```bash
python3 "$CORE" adopt /path/to/vault \
  --generated-at <ISO-UTC> --operation-id adopt-reviewed
python3 "$CORE" adopt /path/to/vault \
  --generated-at <ISO-UTC> --operation-id adopt-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

Ambos comandos son de simulación por defecto. Las bóvedas de usuario nuevas no
reciben ningún remoto del producto de origen.
