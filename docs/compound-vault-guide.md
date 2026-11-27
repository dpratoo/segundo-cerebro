# Arquitectura de la bóveda compuesta

La bóveda compuesta es el modelo operativo de claude-obsidian para una base de
conocimiento local, con citas de fuentes. La base de la versión 2.0.0 reemplaza
el comportamiento histórico de bloqueos por archivo y de escrituras de ciclo de
vida por una selección explícita de la bóveda y transacciones de operación
recuperables.

## Roles

| Rol | Contenido | Política de modificación |
|---|---|---|
| Paquete del producto | Skills, núcleo de Python, scripts, hooks, plantillas | Se cambia solo mediante el desarrollo del producto |
| Bóveda del usuario | Notas, fuentes, registros, configuración de Obsidian | Se cambia mediante operaciones de bóveda revisadas |
| Entorno de ejecución derivado | Bloqueos, diarios, índices de búsqueda, cola de captura | Local a la bóveda, ignorado, recuperable o regenerable |
| Artefacto público | Archivos del producto de la lista de permitidos y muestras sintéticas | Se reconstruye a partir de una instantánea limpia de Git |

Una caché de plugin instalada es siempre código del producto. Nunca se convierte
en la bóveda del usuario. Resuelve el estado de la bóveda mediante `--vault`,
`CLAUDE_OBSIDIAN_VAULT`, la configuración del espacio de trabajo o el
descubrimiento a partir del directorio actual.

La copia de desarrollo y la raíz pública del marketplace son roles distintos,
aunque compartan historial. El código fuente de desarrollo guarda la plantilla
revisada del marketplace en `config/`; el generador de publicaciones la inyecta
en `.claude-plugin/marketplace.json` solo después de seleccionar y auditar el
artefacto limpio. La promoción pública de la rama por defecto usa el artefacto
extraído y requiere la aprobación del propietario.

## Capas de conocimiento

- `inbox/` es una entrada visible y controlada por el usuario. La captura nunca
  la elimina.
- `.raw/` guarda contenidos inmutables y el manifiesto de ingesta heredado.
- `wiki/` guarda las páginas generadas, el índice, la bitácora, la caché
  caliente y los registros de evidencia.
- `.vault-meta/` guarda los bloqueos de ejecución, los diarios de transacciones,
  las colas, los índices y la configuración opcional.

Las bóvedas nuevas incluyen un `.gitignore` que excluye `.vault-meta/` por
completo porque los diarios, las colas y los fragmentos derivados pueden
contener texto de notas, rutas locales o URLs de fuentes. Las bóvedas
existentes deberían adoptar el mismo valor por defecto de forma deliberada, sin
sobrescribir su política de exclusión actual.

`wiki/hot.md` es una caché de contexto acotada, no una transcripción.
`wiki/log.md` anota las operaciones completadas. Los registros de fuentes y de
afirmaciones mantienen la procedencia separada del seguimiento de deltas
heredado.

## Una operación, una transacción

Un guardado, una ingesta, una consolidación, una actualización de canvas, una
fusión de investigación o una reparación de lint aprobada es un único paquete
`claude-obsidian.transaction.v1`:

1. Lee cada destino y registra su SHA-256 actual o su ausencia esperada.
2. Deja que los agentes en paralelo produzcan borradores y evidencia sin
   escrituras compartidas.
3. Fusiona todo el cambio lógico en un solo paquete.
4. Inspecciónalo sin modificarlo.
5. Obtén consentimiento para las consecuencias destructivas, externas o de
   fusión canónica.
6. Aplica una sola vez bajo el bloqueo de toda la bóveda, con duración igual a
   la del proceso.
7. Informa el ID de la operación y las rutas exactas que cambiaron.

El motor guarda en el diario los originales, verifica los hashes de contenido,
usa fsync y reemplazo atómico, y restaura el estado previo tras una aplicación
fallida o interrumpida. Los cambios concurrentes en un destino devuelven el
código de salida de conflicto 75. Vuelve a leer y construye una operación nueva;
nunca fuerces un plan antiguo.

Cada archivo de contenido o de predecesor de una transacción está limitado a
64 MiB; el contenido nuevo agregado y las copias de respaldo de recuperación
agregadas están limitados, cada uno, a 128 MiB. Una transacción tiene como
máximo 1,024 escrituras y verifica de antemano su diario y su resultado contra
el tope de lectura de 8 MiB de la recuperación. La cola de captura usa el mismo
límite para las lecturas y las escrituras (JSON canónico de 8 MiB, como máximo
4,096 entradas), con lo que se preserva la recuperabilidad con recursos
acotados.

La seguridad de las modificaciones se vincula a descriptores de directorio
abiertos, no a búsquedas posteriores por nombre de ruta. La raíz de la bóveda,
el entorno de ejecución de los metadatos, la operación de transacción, las
copias de respaldo, la cola de captura, el estado de los puntos de control y las
publicaciones de la búsqueda permanecen fijados durante toda su ventana de
modificación. Por eso, un reemplazo concurrente de un alias falla de forma
cerrada o se revierte sin tocar un árbol de reemplazo. Estas garantías requieren
WSL/Linux o macOS compatible; Windows nativo y Git Bash no son hosts compatibles
para modificaciones y se rechazan con `UNSUPPORTED_PLATFORM` antes de cualquier
efecto secundario. La inspección de solo lectura y las simulaciones se ejecutan
de forma nativa en Windows, con validación lstat en un instante dado (rechazo de
enlaces simbólicos y junctions) en lugar de la fijación de descriptores. Los
detalles por plataforma y la resolución de problemas de WSL están en la
[guía de Windows y WSL](windows-wsl.md).

Los bytes sin procesar de una fuente pueden proporcionarse mediante escrituras
binarias `content_file` con verificación de hash, pero su modo de destino es
solo de creación. La asignación de direcciones, el frontmatter de las páginas,
el mapa de direcciones, el manifiesto de fuentes, el índice, la bitácora y la
caché caliente pueden cambiar en la misma operación con diario.

Lee [la referencia de transacciones](../skills/wiki/references/operation-transactions.md).

## Rutas de lectura y transporte

Las lecturas del sistema de archivos son la base portátil.
`scripts/detect-transport.sh` informa que la CLI oficial de Obsidian está lista
solo cuando funcionan el comando, la aplicación y la capacidad requerida. La
detección usa por defecto `--peek`, de solo lectura.

La CLI de Obsidian puede acelerar las lecturas y la búsqueda. No es una segunda
vía de modificación: todas las escrituras siguen pasando por el núcleo de
transacciones. Así se evitan las condiciones de carrera entre Obsidian, las
herramientas de los agentes y los agentes en paralelo.

## Búsqueda

El flujo de búsqueda opcional guarda los fragmentos contextuales y el estado de
BM25 dentro de `.vault-meta/`. El aprovisionamiento empieza con una vista
previa:

```bash
bash scripts/setup-retrieve.sh --vault <vault> --no-llm
bash scripts/setup-retrieve.sh --vault <vault> --no-llm --apply
```

BM25 es determinista y local. El reordenamiento opcional por coseno usa por
defecto el modelo multilingüe `nomic-embed-text-v2-moe` de Ollama, que pesa
aproximadamente 958 MB y nunca se descarga de forma automática. Los embeddings
de Nomic usan prefijos de tarea distintos, `search_query:` y `search_document:`.
Quienes ya tengan el modelo v1.5, más pequeño y orientado al inglés, pueden
seleccionarlo de forma explícita con `--model nomic-embed-text`; las bóvedas
multilingües deberían conservar el valor por defecto v2. Nomic v2 tiene un
contexto de entrada de 512 tokens, y Ollama trunca por defecto las entradas de
embeddings más largas; BM25 sigue puntuando el fragmento completo. Si falta el
modelo seleccionado, falla la prueba de modelo solo local o falla una etapa de
embeddings, los resultados recurren por completo al orden y a las puntuaciones
de BM25. La prueba exige que el estado del servidor indique la nube
desactivada, un digest instalado válido y metadatos locales del modelo no
vacíos antes de trabajar con consultas, fragmentos o cachés. Los registros de
fragmentos eliminados, modificados o que escapan de su directorio se rechazan, y
la eliminación de páginas duplicadas ocurre antes del top-K final.

Las consultas de búsqueda están acotadas a 8,000 caracteres normalizados y la
cantidad de resultados, de 1 a 1,000. Las consultas demasiado largas y los
límites no válidos fallan de forma explícita. Una solicitud de modelo de Ollama
sin etiqueta coincide solo con el nombre sin etiqueta correspondiente o con su
alias `:latest`; las demás etiquetas instaladas deben seleccionarse por su
nombre exacto. Las entradas de la caché de embeddings se limitan al digest
verificado del modelo.

Las llamadas a modelos para los prefijos contextuales requieren
`--allow-egress`. Ollama remoto requiere `--allow-remote-ollama`. Ninguna de las
dos se infiere solo a partir de una variable de entorno.

## Evidencia

El registro de fuentes guarda la identidad del contenido, la autoridad, la
independencia, la vigencia, el estado de revisión y las páginas enlazadas. El
registro de afirmaciones guarda las afirmaciones falsables, el respaldo, las
contradicciones, la confianza, el riesgo y la evaluación.

- Las afirmaciones aceptadas necesitan un respaldo vigente, activo y no
  sintético.
- Las afirmaciones aceptadas de alto riesgo necesitan dos fuentes
  independientes.
- Las fuentes con una misma clave de independencia cuentan como una sola línea
  de evidencia.
- Las grafías de URL equivalentes según los RFC cuentan como un solo origen,
  incluidos IPv6 normalizado, IDN, la codificación porcentual Unicode/UTF-8 y
  los puertos por defecto.
- Las contradicciones siguen visibles.
- Sin respaldo es un estado válido; las citas inventadas no lo son.

Lee [la referencia de procedencia](../skills/wiki/references/provenance.md).

## Hooks

El hook SessionStart de Claude es silencioso por defecto. Emite contexto
caliente acotado y saneado solo cuando se resuelve una bóveda de usuario y el
usuario ha exportado explícitamente `CLAUDE_OBSIDIAN_SESSION_CONTEXT=1`; la
salida estándar del hook se convierte en contexto del modelo, por lo que esta
activación voluntaria es una decisión de salida de red. El hook Stop informa de
las transacciones incompletas. Los hooks no actualizan notas, no capturan
conversaciones, no agregan archivos al área de preparación ni hacen commits de
Git. Los hosts sin hooks usan los mismos flujos de trabajo del núcleo.

## Captura

La captura de bytes del sistema de archivos es el único adaptador implementado
internamente. Realiza una verificación previa completa de solo lectura y luego
la CLI aplica todas las copias sin procesar nuevas, direccionadas por contenido,
como una sola transacción con soporte binario. Los metadatos de formato de
imágenes, PDF y EPUB son locales; la extracción semántica no viene incorporada.
Las acciones de URL, YouTube y OCR son planes de consentimiento inertes para un
ejecutor configurado por separado.

## Mantenimiento y recuperación

```bash
python3 scripts/claude-obsidian.py doctor --vault <vault>
python3 scripts/claude-obsidian.py lint --vault <vault> --as-of YYYY-MM-DD
python3 scripts/claude-obsidian.py transaction recover --vault <vault>
```

El lint es determinista para su fecha de auditoría UTC declarada y de solo
lectura. Cualquier corrección es una transacción revisada aparte. Los puntos de
control de Git también son aparte y explícitos; verifican los bytes exactos de
los blobs, rechazan contenido que ya estuviera en el área de preparación,
avanzan el historial mediante comparar e intercambiar (compare-and-swap) y
excluyen los bytes sin procesar a menos que el usuario lo habilite de forma
expresa. Si queda un bloqueo obsoleto tras una caída, primero verifica que no
haya ningún proceso de escritura activo; solo entonces usa
`transaction recover --force-stale-lock`. Nunca automatices esa anulación.

## Ruta de actualización

Las estructuras existentes siguen siendo legibles. Haz una vista previa de la
migración aditiva antes de aplicarla:

```bash
python3 scripts/claude-obsidian.py migrate --vault <vault> \
  --generated-at <ISO-UTC> --operation-id migrate-reviewed
python3 scripts/claude-obsidian.py migrate --vault <vault> \
  --generated-at <ISO-UTC> --operation-id migrate-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

La migración agrega el estado faltante del espacio de trabajo y de la
procedencia, conserva el manifiesto heredado byte a byte y no infiere
afirmaciones a partir de la prosa. El obsoleto `scripts/wiki-lock.sh` se
mantiene solo por compatibilidad con v1 y no debe usarse en flujos de trabajo
nuevos.
