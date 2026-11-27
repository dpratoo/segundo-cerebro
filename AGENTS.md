# claude-obsidian: instrucciones para agentes

claude-obsidian es un paquete de Agent Skills, local por defecto, para construir
bases de conocimiento de Obsidian que citan sus fuentes y se acumulan con el
tiempo. También incluye un adaptador de plugin para Claude Code. El flujo de
trabajo portátil se implementa en `skills/` y en el núcleo `claude_obsidian/` de
biblioteca estándar; los hooks del host nunca definen el comportamiento del
conocimiento.

## Límites entre producto y bóveda

- Este repositorio es la fuente del producto. No es la bóveda de usuario por
  defecto.
- Una bóveda de usuario es el directorio que contiene `.claude-obsidian.json`,
  `wiki/` y `.raw/`. El estado mutable siempre pertenece a ella.
- `templates/vault/` es la semilla distribuible. `wiki/`, `.raw/` y
  `.vault-meta/` en la raíz son estado de colaboradores y se excluyen de los
  artefactos públicos.
- Nunca derives una bóveda de usuario de la caché del plugin ni de
  `${CLAUDE_PLUGIN_ROOT}`.
- Una copia de trabajo que contiene estado de bóveda de colaboradores no tiene
  catálogo de marketplace. `config/public-marketplace.json` se inyecta como
  `.claude-plugin/marketplace.json` solo dentro del artefacto de publicación
  auditado. Un artefacto extraído y limpio para distribución puede conservar ese
  manifiesto exacto y reconstruirse de forma idempotente. Una rama predeterminada
  pública debe poblarse a partir del artefacto limpio, nunca haciendo push del
  estado de la bóveda de colaboradores.

Resuelve una bóveda en este orden: `--vault` explícito,
`CLAUDE_OBSIDIAN_VAULT`, el `.claude-obsidian.json` más cercano y, por último,
una bóveda inequívoca en el directorio actual o por encima de él. Falla de forma
cerrada cuando no se selecciona ninguna bóveda.

## Arranque

1. Lee este archivo. En una copia de desarrollo, lee también el `CLAUDE.md` raíz
   exclusivo del host cuando exista; los artefactos de publicación lo omiten a
   propósito.
2. Lee completa la skill seleccionada.
3. Lee solo las referencias a las que esa skill te dirige.
4. Resuelve la bóveda del usuario. Si existe `wiki/hot.md`, léelo en silencio.
5. Para una bóveda nueva, ejecuta primero `python3 scripts/claude-obsidian.py init PATH`;
   aplica solo después de revisar la simulación. Usa `adopt` para una bóveda
   existente.

## Skills canónicas

Las 15 skills viven en `skills/<name>/SKILL.md`. Usan el subconjunto portátil de
frontmatter de Agent Skills: exactamente `name` y `description`. No agregues
archivos reflejados en `commands/`; Claude invoca las skills del plugin por
nombres con espacio de nombres, como `/claude-obsidian:wiki`.

Los flujos de trabajo principales son `wiki`, `save`, `wiki-ingest`, `wiki-query`
y `wiki-lint`. Las extensiones son `autoresearch`, `canvas`, `defuddle`,
`wiki-fold`, `wiki-mode`, `wiki-retrieve` y `wiki-cli`. Las skills de referencia
son `obsidian-markdown`, `obsidian-bases` y `think`.

## Protocolo de modificación

Una operación lógica de conocimiento es una transacción recuperable:

1. Lee los destinos y registra los valores SHA-256 esperados.
2. Deja que los agentes en paralelo devuelvan solo borradores y evidencia.
3. Fusiona los borradores en un único paquete `claude-obsidian.transaction.v1`.
4. Inspecciona el paquete y luego aplícalo una sola vez mediante
   `scripts/claude-obsidian.py`.
5. Informa el ID de la operación y las rutas exactas modificadas.

No uses escrituras compartidas directas, el auxiliar obsoleto `wiki-lock.sh` ni
commits automáticos genéricos del ciclo de vida. Los puntos de control de Git son
independientes y explícitos. Las cargas de fuentes sin procesar son solo de
creación; `.raw/.manifest.json` es el único archivo mutable de metadatos
heredados de las fuentes sin procesar. Las reparaciones destructivas, la salida de red remota y
las fusiones de investigación canónica requieren consentimiento explícito.

## Convenciones de la bóveda

- `inbox/`: entrada visible de capturas; nunca se elimina de forma automática.
- `.raw/`: cargas de fuentes inmutables y manifiesto delta heredado.
- `wiki/`: páginas de conocimiento generadas.
- `wiki/meta/ledgers/`: procedencia de fuentes y afirmaciones.
- `wiki/hot.md`: contexto reciente acotado, nunca una transcripción.
- `wiki/log.md`: historial de operaciones, las más recientes primero.
- `.vault-meta/`: bloqueos, diarios, índices, colas y configuración de ejecución
  ignorados.

Usa Obsidian Flavored Markdown: propiedades YAML planas, fechas `YYYY-MM-DD`,
wikilinks, incrustaciones y destacados válidos. Nunca inventes localizadores de
evidencia, citas textuales, números de página ni niveles de confianza.

## Verificación

Ejecuta `make test` después de los cambios de comportamiento. Este comando
ejecuta cada suite de Python y de shell, además de los contratos de producto, capacidades, paquete,
hooks y manifiestos. Los artefactos públicos se construyen en local con
`release build` y se auditan sin publicar. Ningún agente puede hacer push, crear
etiquetas, abrir o modificar issues, ni publicar una versión sin la aprobación
explícita del propietario.

La inyección de contexto de SessionStart de Claude está deshabilitada por defecto.
Trata `CLAUDE_OBSIDIAN_SESSION_CONTEXT=1` como consentimiento explícito del
usuario para poner datos acotados de `wiki/hot.md` en el contexto del modelo;
nunca lo definas de forma automática. Una bóveda configurada en el espacio de
trabajo fuera del proyecto requiere además una ruta exacta en
`CLAUDE_OBSIDIAN_SESSION_CONTEXT_VAULT`.

## Referencia

- Repositorio canónico público: https://github.com/dpratoo/segundo-cerebro
- Proyecto original: https://github.com/AgriciDaniel/claude-obsidian
- Patrón LLM Wiki: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Primitivas de Obsidian: https://github.com/kepano/obsidian-skills
