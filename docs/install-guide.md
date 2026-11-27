# Instalar claude-obsidian

claude-obsidian tiene dos partes independientes:

1. el paquete del producto (skills, núcleo portátil, adaptador de Claude y
   plantillas);
2. una bóveda de Obsidian propiedad del usuario que contiene conocimiento
   modificable.

No uses la caché de un plugin instalado como bóveda. Un clon del código fuente
sirve para el desarrollo, pero una bóveda normal de usuario debe ser un
directorio aparte.

## Requisitos

- Python 3.11 o superior
- un host compatible con Agent Skills, o Claude Code para el adaptador del plugin
- Obsidian, si quieres su editor visual
- Bash para el instalador y para los scripts opcionales de extensiones heredadas
- Git solo para el desarrollo desde el código fuente, las compilaciones de
  publicación o los puntos de control explícitos
- En Windows: WSL para escribir en la bóveda; Windows nativo admite la
  inspección de solo lectura y las simulaciones, consulta la
  [guía de Windows y WSL](windows-wsl.md)

## Marketplace de Claude Code

Agrega el catálogo público e instala el plugin con su espacio de nombres:

```bash
claude plugin marketplace add dpratoo/segundo-cerebro
claude plugin install claude-obsidian@segundo-cerebro
claude plugin list
```

¿Actualizas desde 2.x o 3.0.0? Consulta [Actualización y reversión](#actualización-y-reversión).

Un árbol de desarrollo privado que guarda el estado de la bóveda de
colaboradores no tiene `.claude-plugin/marketplace.json`; puede contener el
estado de la bóveda de colaboradores y no debe agregarse como marketplace. El
constructor de publicaciones determinista inyecta ese manifiesto solo en su
salida auditada. La rama pública por defecto debe promoverse desde el artefacto
auditado extraído antes de anunciar estos comandos del marketplace para una
versión nueva.

Invoca las skills como `/claude-obsidian:wiki`,
`/claude-obsidian:wiki-ingest` y `/claude-obsidian:save`.

La caché del plugin contiene recursos del producto de solo lectura. Ejecuta
Claude desde la bóveda del usuario, define `CLAUDE_OBSIDIAN_VAULT` o pasa
`--vault` a los comandos portátiles.

## Desarrollo local del plugin de Claude

Desde un clon del producto:

```bash
claude --plugin-dir <product-repository>
```

Este modo sirve para probar cambios sin instalar. Las skills conservan su
espacio de nombres. No convierte el repositorio del producto en una bóveda de
usuario.

## Hosts portátiles de Agent Skills

Por defecto, el instalador muestra una vista previa sin escritura para Codex,
OpenCode y Gemini:

```bash
bash scripts/setup-multi-agent.sh
bash scripts/setup-multi-agent.sh --apply
```

Enlaza cada directorio canónico `skills/<name>/` en el esquema de
descubrimiento directo `<skill-root>/<name>/SKILL.md` del host. Los destinos se
crean solo cuando no existen; nunca se reemplaza una skill ni un enlace
existente. Comprueba si todo está listo sin escribir:

```bash
bash scripts/setup-multi-agent.sh --check
```

Cursor y Windsurf usan un descubrimiento local al espacio de trabajo y
requieren un espacio de trabajo explícito:

```bash
bash scripts/setup-multi-agent.sh --host cursor --host windsurf \
  --workspace <workspace> --apply
```

ZCode es opcional y de nivel de usuario (no necesita `--workspace`):

```bash
bash scripts/setup-multi-agent.sh --host zcode
bash scripts/setup-multi-agent.sh --host zcode --apply
```

También puedes crear manualmente enlaces equivalentes por skill. Para cada
`<name>` dentro del directorio `skills/` del producto, enlaza ese directorio en:

```text
Codex:     ~/.agents/skills/<name>          -> <product-repository>/skills/<name>
OpenCode:  ~/.config/opencode/skills/<name> -> <product-repository>/skills/<name>
Gemini:    ~/.gemini/skills/<name>          -> <product-repository>/skills/<name>
ZCode:     ~/.zcode/skills/<name>           -> <product-repository>/skills/<name>
Cursor:    <workspace>/.cursor/skills/<name>   -> <product-repository>/skills/<name>
Windsurf:  <workspace>/.windsurf/skills/<name> -> <product-repository>/skills/<name>
```

## Crear una bóveda nueva

Revisa primero el plan de inicialización:

```bash
python3 scripts/claude-obsidian.py init <new-vault> \
  --generated-at <ISO-UTC> --operation-id init-reviewed
```

Aplica la misma operación solo después de que el destino y las rutas
modificadas se vean correctos:

```bash
python3 scripts/claude-obsidian.py init <new-vault> \
  --generated-at <ISO-UTC> --operation-id init-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

La bóveda generada contiene:

- `.gitignore`, valores por defecto que cuidan la privacidad y excluyen el
  estado de ejecución de `.vault-meta/`, el estado del espacio de trabajo de
  Obsidian y la configuración de arranque `.mcp.json` en uso;
- `.claude-obsidian.json`, identidad del espacio de trabajo y selección de la
  bóveda;
- `inbox/`, entrada visible de fuentes;
- `.raw/`, contenidos de fuentes inmutables y manifiesto delta heredado;
- `wiki/`, índice, bitácora, caché caliente, vista general y notas generadas;
- `.obsidian/`, valores por defecto mínimos y no destructivos de Obsidian;
- `.vault-meta/`, estado de ejecución ignorado que se crea cuando hace falta.

La inicialización no agrega un remoto de Git del proyecto de origen ni instala
complementos comunitarios. Abre el directorio nuevo desde el selector de bóvedas
de Obsidian.

## Adoptar una bóveda existente

La adopción analiza un directorio de Obsidian existente y propone solo los
metadatos del producto y los archivos de base que faltan:

```bash
python3 scripts/claude-obsidian.py adopt <existing-vault> \
  --generated-at <ISO-UTC> --operation-id adopt-reviewed
python3 scripts/claude-obsidian.py adopt <existing-vault> \
  --generated-at <ISO-UTC> --operation-id adopt-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

Conserva las notas existentes y el JSON de Obsidian. `--force` es
intencionalmente independiente y debería usarse solo después de inspeccionar los
destinos de reemplazo.

Para estructuras antiguas de claude-obsidian, agrega registros de procedencia y
la configuración del espacio de trabajo con una migración aditiva:

```bash
python3 scripts/claude-obsidian.py migrate --vault <existing-vault> \
  --generated-at <ISO-UTC> --operation-id migrate-reviewed
python3 scripts/claude-obsidian.py migrate --vault <existing-vault> \
  --generated-at <ISO-UTC> --operation-id migrate-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

La migración es idempotente, no infiere afirmaciones a partir de la prosa y
deja el `.raw/.manifest.json` heredado sin cambios, byte por byte.

## Selección de la bóveda

Los comandos que modifican usan esta precedencia:

1. `--vault <path>`
2. `CLAUDE_OBSIDIAN_VAULT`
3. el `.claude-obsidian.json` más cercano
4. la bóveda inicializada sin ambigüedad más cercana desde el directorio actual

Si la selección falla, el comando termina sin modificar nada. La raíz del
producto o del plugin se rechaza como bóveda implícita.

Verifica una bóveda seleccionada:

```bash
python3 scripts/claude-obsidian.py doctor --vault <vault>
python3 scripts/claude-obsidian.py contracts --verify --vault <vault>
```

Doctor revisa la seguridad del directorio de metadatos y los permisos de
escritura y de búsqueda sin crear archivos. Un `.vault-meta` ausente está listo
solo cuando el directorio de la bóveda permite crearlo. La disponibilidad es un
diagnóstico de un momento dado; las transacciones vuelven a revisar rutas,
conflictos y permisos antes de aplicar cambios.

## Configuración opcional

El transporte portátil del sistema de archivos siempre sigue disponible. Detecta
una Obsidian CLI activa y compatible sin guardar una instantánea:

```bash
bash scripts/detect-transport.sh --peek --vault <vault>
```

Las extensiones opcionales son explícitas y se limitan a una bóveda:

```bash
bash scripts/setup-mode.sh --vault <vault>
bash scripts/setup-retrieve.sh --vault <vault>
bash scripts/setup-dragonscale.sh --vault <vault>
```

Lee la vista previa de cada script antes de aplicarlo. La búsqueda puede usar
solo BM25 local; los prefijos contextuales basados en modelos o los endpoints
remotos requieren consentimiento explícito de salida de red. Las herramientas
opcionales como Ollama y defuddle se detectan según sus capacidades.

## Primera operación

Coloca una fuente en `inbox/`. Inspecciona el plan de captura de bytes:

```bash
python3 scripts/claude-obsidian.py capture plan --vault <vault>
```

Crea copias inmutables direccionadas por contenido solo cuando el plan sea correcto:

```bash
python3 scripts/claude-obsidian.py capture apply --vault <vault> \
  --generated-at <ISO-UTC> --operation-id capture-reviewed
python3 scripts/claude-obsidian.py capture apply --vault <vault> \
  --generated-at <ISO-UTC> --operation-id capture-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

Después invoca la skill `wiki-ingest` del host. La extracción semántica de
imágenes, PDF y EPUB no está integrada en el núcleo; por ahora esos formatos
reciben metadatos acotados, a menos que se apruebe explícitamente un adaptador
configurado por separado.

## Actualización y reversión

El plugin de Claude es `claude-obsidian` y sus comandos son
`/claude-obsidian:*`. Desde 2.x, actualízalo como de costumbre:

```bash
claude plugin marketplace update segundo-cerebro
claude plugin update claude-obsidian@segundo-cerebro
```

¿Vienes del plugin original en inglés
(`claude-obsidian@agricidaniel-claude-obsidian`)? Desinstálalo y quita su
marketplace antes de instalar esta versión, porque los dos usan el mismo nombre
de plugin y los mismos comandos `/claude-obsidian:*`:

```bash
claude plugin uninstall claude-obsidian@agricidaniel-claude-obsidian
claude plugin marketplace remove agricidaniel-claude-obsidian
claude plugin marketplace add dpratoo/segundo-cerebro
claude plugin install claude-obsidian@segundo-cerebro
```

Reinicia Claude Code después de cualquiera de los dos caminos. El nombre
`agricidaniel-obsidian` (versión 3.0.0) solo existió en el proyecto original; la
[migración de espacio de nombres](namespace-migration.md) explica ese caso.

Actualiza el código del producto de forma independiente de la bóveda del
usuario. Antes de una migración o de una ingesta grande, haz una copia de
respaldo o una instantánea normal. Las escrituras de conocimiento se registran
en un diario; ejecuta la recuperación después de una operación interrumpida:

```bash
python3 scripts/claude-obsidian.py transaction recover --vault <vault>
```

La recuperación preserva, por prudencia, las identidades de bloqueo obsoletas o
ajenas. Solo después de confirmar que no hay ningún escritor activo puede un
operador agregar `--force-stale-lock`.

El historial de Git es opcional y nunca automático. Para crear un punto de
control de exactamente una transacción completada:

```bash
python3 scripts/claude-obsidian.py checkpoint <operation-id> --vault <vault> \
  --as-of YYYY-MM-DD
```

El punto de control usa un índice temporal, verifica los bytes exactos de los
blobs de Git, rechaza cualquier estado ya preparado (staged) y reanuda la
finalización interrumpida de una referencia o del índice a partir de su registro
pendiente, local a la bóveda.

## Desinstalar

Quita la integración con el host, no la bóveda:

```bash
claude plugin uninstall claude-obsidian@segundo-cerebro
claude plugin marketplace remove segundo-cerebro
```

En los hosts portátiles, quita solo los enlaces por skill que informó el
instalador. Las notas, fuentes, registros y ajustes de Obsidian del usuario no
se tocan.

## Solución de problemas

| Síntoma | Qué revisar |
|---|---|
| La skill no se descubre | Confirma que `<host-skill-root>/<name>/SKILL.md` resuelve a la skill del producto correspondiente; vuelve a ejecutar el instalador con `--check`. |
| El comando dice que no hay ninguna bóveda seleccionada | Ejecútalo desde la bóveda, pasa `--vault` o define `CLAUDE_OBSIDIAN_VAULT`. |
| Rechazo por raíz del plugin | Selecciona una bóveda de usuario aparte; no se admiten escrituras en la caché del plugin. |
| Conflicto de transacción / código de salida 75 | Hay otra operación activa o cambió un destino; vuelve a leer, reconstruye e inspecciona un paquete nuevo. |
| Obsidian CLI no está disponible | Usa lecturas del sistema de archivos; inicia o actualiza Obsidian antes de volver a intentar el transporte de la CLI. |
| El adaptador de captura no está implementado | Inspecciona `capture adapters`; configura un ejecutor aparte solo con consentimiento explícito. |
| Escrituras rechazadas con `UNSUPPORTED_PLATFORM` en Windows | Escribir en la bóveda requiere WSL; consulta la [guía de Windows y WSL](windows-wsl.md). |
| WSL instalado pero `wsl --status` se cuelga | Sigue el flujo de diagnóstico y reporte de Microsoft en la [guía de Windows y WSL](windows-wsl.md#solución-de-problemas-de-wsl); no supongas una causa sin evidencia. |
| La aprobación de una simulación nativa falla en WSL con `PLAN_CHANGED` | Los hashes de aprobación se vinculan al entorno que revisa; repite la simulación dentro de WSL ([detalles](windows-wsl.md#solución-de-problemas-de-wsl)). |

Ejecuta `make test` en el repositorio del producto al desarrollar o empaquetar cambios.
