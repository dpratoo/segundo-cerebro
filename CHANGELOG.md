# Registro de cambios

Los cambios notables de claude-obsidian se registran aquí con las categorías de
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) y el
[Versionado Semántico](https://semver.org/). El historial de Git conserva el
detalle de la implementación de las versiones anteriores.

## [Unreleased]

### Añadido

- Traducción completa al español neutro: documentación, skills, agentes,
  plantillas de bóveda, imágenes del README y mensajes visibles del código. Se
  distribuye como `claude-obsidian@segundo-cerebro` desde https://github.com/dpratoo/segundo-cerebro.

## [3.0.1] - 2026-10-21

Restaura el nombre del plugin de Claude, `claude-obsidian`, de modo que los
comandos vuelven a ser `/claude-obsidian:*`. Nada más cambia.

### Actualización

Desde 2.x, es una actualización normal y tus comandos nunca cambian:

```bash
claude plugin marketplace update agricidaniel-claude-obsidian
claude plugin update claude-obsidian@agricidaniel-claude-obsidian
```

Si instalaste 3.0.0 (`agricidaniel-obsidian`), la actualización del marketplace
devuelve tu configuración a su estado anterior; después instala una sola vez:

```bash
claude plugin marketplace update agricidaniel-claude-obsidian
claude plugin install claude-obsidian@agricidaniel-claude-obsidian
```

Reinicia Claude Code después de cualquiera de las dos rutas. La configuración
administrada que nombre `agricidaniel-obsidian` debe cambiar la clave a mano.

### Cambiado

- El plugin de Claude vuelve a ser `claude-obsidian`. El mapa `renames` del
  marketplace ahora migra `agricidaniel-obsidian` de vuelta a él; el mapa de
  3.0.0, en sentido contrario, se elimina, porque un nombre no puede ser a la
  vez actual y anterior.
- `claude plugin validate` informa que el nombre está reservado y
  `claude plugin tag` lo rechaza, aunque Claude Code lo instala y lo carga.
  Conservar el nombre publicado es una excepción aprobada por el propietario:
  `package validate` acepta `claude-obsidian` y sigue rechazando cualquier otro
  nombre reservado.

## [3.0.0] - 2026-10-21

Para actualizar, sigue en su lugar las instrucciones de 3.0.1: restaura el
nombre `claude-obsidian` que esta versión cambió.

Versión de endurecimiento: transacciones recuperables, lint y búsqueda
deterministas, evaluación sin conexión, controles explícitos de proveedores y un
plugin de Claude con otro nombre. El cambio de nombre es el cambio incompatible;
las bóvedas no necesitan migración.

### Actualización desde 2.x

El plugin de Claude ahora es `agricidaniel-obsidian`, así que los comandos
`/claude-obsidian:*` pasan a ser `/agricidaniel-obsidian:*`. No se ofrece ningún
alias. Ejecuta:

```bash
claude plugin marketplace update agricidaniel-claude-obsidian
claude plugin install agricidaniel-obsidian@agricidaniel-claude-obsidian
```

Después reinicia Claude Code. Hasta que se ejecute la instalación, el plugin no
está instalado. La configuración administrada debe cambiar la clave a mano. Los
prefijos contextuales ya no recurren a `claude -p` (consulta Eliminado). Consulta
la [migración de espacio de nombres](docs/namespace-migration.md) para la
verificación y la reversión.

### Cambiado

- El plugin de Claude pasa de llamarse `claude-obsidian` a
  `agricidaniel-obsidian`, porque Claude Code reserva los nombres de plugin que
  empiezan por `claude-`. El mapa `renames` del marketplace migra las
  instalaciones existentes en lugar de informar que el plugin falta; la
  validación del paquete rechaza las cadenas de renames que no se resuelven. El
  repositorio, el paquete de Python y los formatos de bóveda conservan el nombre
  claude-obsidian.
- Los prefijos contextuales en caché se reutilizan solo cuando coinciden con la
  configuración actual del proveedor. Los prefijos guardados en caché por
  versiones anteriores no registran ninguna configuración, así que la primera
  ejecución tras actualizar los regenera todos; con `--allow-egress` eso vuelve a
  enviar cada página a la API configurada.

### Corregido

- La fragmentación contextual y la indexación BM25 leen páginas cuyos nombres
  usan Unicode descompuesto (macOS, o una bóveda sincronizada desde allí) o, en
  POSIX, una barra invertida. Una sola página así detenía la fragmentación de
  toda la bóveda.
- Las rutas de `wiki-mode` quitan `#`, `^`, `[` y `]` de los nombres de archivo
  que conservan el título, ya que Obsidian no puede enlazarlos. Las rutas
  genéricas de fuentes y preguntas conservan el título y reutilizan una página
  con slug organizada por una versión anterior en lugar de sugerir un duplicado.
- Los fragmentos de código en línea del lint terminan en los límites de párrafo,
  de modo que una comilla invertida suelta ya no oculta enlaces y encabezados
  posteriores. Los analizadores de enlaces, encabezados, wikilinks, matemáticas y
  fragmentos de código en línea son lineales en páginas grandes y adversarias. La
  continuación diferida con sangría, las imágenes dentro de etiquetas de enlace,
  los cercados dentro de citas y destacados, los candidatos Setext diferidos, los
  enlaces a encabezados con los signos que Obsidian elimina, los destinos
  literales de wikilinks y los destinos de hoja ocultos siguen el comportamiento
  de Obsidian y CommonMark. Un `wiki/` analizado directamente resuelve archivos
  del directorio padre solo cuando el padre es una bóveda.
- El teselado deja de enviar texto de páginas tras el primer fallo del proveedor.
  Las respuestas de Ollama se analizan de forma estricta, así que las claves
  duplicadas no pueden ocultar marcadores remotos; las respuestas HTTP mal
  formadas recurren a la alternativa en lugar de lanzar un error. Las solicitudes
  al proveedor tienen un único plazo de reloj, un modelo en la nube instalado que
  no guarda relación ya no bloquea el modo local, y una caída de Ollama conserva
  los prefijos locales válidos y el índice BM25.
- Una transacción cuyo destino, aún no aplicado, se elimina o se edita
  externamente se revierte con el conflicto original en lugar de dejar un diario
  que bloquea operaciones posteriores. El estado de ejecución y los paquetes muy
  anidados o con tipos incorrectos devuelven errores controlados, la
  reproducción rechaza un diario `prepared` y las lecturas de archivos regulares
  se abren sin bloqueo, de modo que las FIFO se rechazan en lugar de quedarse
  colgadas.
- Las rutas rápidas de los hooks emiten UTF-8 en codificaciones de consola
  heredadas. Las comprobaciones de flujo de trabajo aceptan el diseño de bitácora
  sembrado, acotan `hot.md` al límite de contexto de sesión, exigen que los
  catálogos nuevos sean alcanzables y que la ingesta registre una fuente y un
  cambio real en el registro, e informan los ID de operación reutilizados como
  `OPERATION_ID_REUSED`. Doctor informa que un `wiki/` o un estado de ejecución
  que sean enlaces simbólicos o no sean directorios no son seguros.
- La compactación por capacidad reescribe solo los registros que están cerca o
  por encima de su capacidad y rechaza la entrada que no cabe antes de
  analizarla; las migraciones escriben registros canónicos compactos. La
  validación de anclas de afirmaciones ya no depende de `assert`.
- La recuperación respeta un marcador de operación en curso registrado en el
  diario, de modo que una reversión fallida o interrumpida nunca deshace ni
  informa una escritura que no comenzó. Los protocolos de enlace HTTPS con
  proveedores comparten el plazo de la solicitud, y las comprobaciones locales de
  nombres de plugin reservados siguen las reglas de separadores del host.
- La verificación se ejecuta en cada pull request, incluidos los PR apilados
  sobre la rama de otro PR. Dependabot propone actualizaciones de GitHub Actions
  con período de espera y fijadas por SHA, y CodeQL analiza el núcleo de Python y
  los flujos de trabajo.
- El desacuerdo sobre Duration en Bases cita solo la evidencia registrada (el
  registro de cambios de 1.9.3 y la skill fijada de upstream), con los hashes de sus
  alternativas locales fijados de nuevo. `scripts/evaluate-prompts.py` es
  ejecutable, igual que sus archivos hermanos.
- Una sonda de la CLI de Obsidian que agota su tiempo recurre al sistema de
  archivos en hosts sin `os.killpg`, y el lint nombra el código de error y la
  recuperación de capacidad cuando un registro de procedencia supera su límite.
- El análisis de encabezados ya no falla con una almohadilla seguida de código en
  línea ni con código en línea que contiene separadores de línea Unicode. Los
  encabezados Setext tras líneas de contenedor que no son párrafos, la
  continuación diferida de citas, las almohadillas con sangría de tabulación y
  las líneas `=` diferidas dentro de fragmentos de código en línea siguen
  CommonMark. La inspección de flujos de trabajo analiza cada catálogo una sola
  vez, y sus guías indican que un MOC nuevo debe enlazarse desde un catálogo
  declarado en `workflow.catalogs`.
- Los ejemplos del evaluador usan directorios temporales físicos. Los fixtures de
  pruebas compatibles con macOS conservan sus comprobaciones explícitas de
  enlaces simbólicos y de entradas no válidas bajo rutas temporales con alias,
  sin debilitar el confinamiento de producción.
- La limpieza de pruebas para desarrolladores ya no expone un objetivo que borre
  los diarios de recuperación de transacciones. Doctor rechaza rutas de metadatos
  no seguras y comprueba tanto el acceso de escritura como el de búsqueda sin
  modificar la bóveda seleccionada.
- El lint directo de la raíz de la wiki resuelve adjuntos hermanos dentro de la
  bóveda contenedora y conserva el alcance del informe. Las lecturas confinadas
  de metadatos rechazan los intercambios de archivos y de ancestros antes de leer
  bytes externos. BM25 trata el UTF-8 mal formado como obsoleto.
- Los proveedores semánticos comparten una prueba de modelo local con la nube
  deshabilitada, una selección exacta de modelo y una identidad de caché ligada
  al digest. El teselado informa el trabajo incompleto con el código de salida 12
  y conserva su caché anterior tras fallos de embeddings, incluidas las
  discrepancias de dimensión de vectores nuevos.
- La agrupación de procedencia usa búsquedas por identidad, y las afirmaciones
  repetidas comparten una verificación de páginas y un análisis de anclas
  acotados dentro de cada llamada de validación.
- Los permisos de Canvas exigen consentimiento explícito para las ediciones
  destructivas del tablero. La documentación de Defuddle describe la
  planificación de la extracción y la captura local. Se elimina la prueba
  histórica de benchmark, cuyos auxiliares nunca se distribuyeron.
- SessionStart también coincide con las sesiones bifurcadas en los hosts actuales
  de Claude Code, y conserva el consentimiento explícito de contexto y el
  comportamiento de hook de solo lectura.
- La navegación de catálogos de flujos de trabajo ignora los comentarios YAML y
  acepta wikilinks admitidos en propiedades activas mediante el analizador de
  frontmatter compartido.
- La búsqueda omite los registros de fragmentos dañados, conserva los resultados
  sanos y cuenta cada registro rechazado. La decodificación estricta de páginas
  impide que un UTF-8 no válido coincida con un carácter de reemplazo previo. Los
  fallos por límite de conversión de JSON usan errores controlados de caché,
  umbral y candidatos, o la alternativa documentada.
- La recuperación de un reemplazo interrumpido conserva como conflictos los
  destinos eliminados externamente. La reproducción de un flujo de trabajo
  completado rechaza comprobantes y formas de escritura mal formados con errores
  controlados antes de la modificación.
- El lint resuelve alias entrecomillados con comas y comentarios, etiquetas de
  enlaces en línea y destinos de encabezados con delimitadores balanceados, y
  secciones vacías que solo contienen comentarios. Las secuencias de corchetes
  mal formadas se analizan sin búsquedas repetidas de sufijos.
- La generación de prefijos rechaza el UTF-8 mal formado antes de cualquier
  trabajo con el proveedor o la caché. Los endpoints de modelos locales usan
  loopback numérico en lugar de la resolución ambiental de localhost.
- Los embeddings y el reordenamiento deshabilitan los proxies ambientales y las
  redirecciones, acotan las lecturas de respuestas y validan las entradas de
  consulta, candidatos y umbral antes de cualquier trabajo con el proveedor o la
  caché. Las cachés y umbrales con UTF-8 mal formado siguen errores controlados.
- El fixture de Save sin conexión impone un contrato explícito y acotado de
  título a partir de palabras de la fuente y cuerpos de nota exactos. La guía de
  Canvas usa el catálogo admitido y distingue las ediciones de nodos de la
  eliminación o el cambio de nombre de archivos de tablero, que no se admiten; la
  búsqueda describe solo los proveedores admitidos.
- Los catálogos de flujos de trabajo y las notas seleccionadas rechazan las rutas
  ocultas. La reproducción completada puede verificar el contenido confirmado
  después de eliminar los borradores desechables, sin relajar las comprobaciones
  de paquete, aprobación ni deriva del resultado. Las bitácoras de lotes exigen
  fechas de calendario reales.
- La reproducción de una transacción completada requiere su diario conservado y
  su paquete expandido, con identidad de resultado, cobertura de escritura y
  hashes de contenido coincidentes.
- El lint reconoce los encabezados Setext que respetan las regiones protegidas
  en la resolución de fragmentos, las jerarquías de encabezados y las
  comprobaciones de secciones vacías. Las etiquetas con estilo conservan el
  código en línea visible; los bloques HTML sin procesar no pueden fabricar
  coincidencias de encabezados Markdown.
- La generación opcional con proveedores tiene un trabajo de solicitudes acotado
  y un cortacircuitos ante fallos. La reutilización de fragmentos sin cambios
  valida el esquema vigente de los registros y los invariantes de contenido antes
  de omitir la regeneración.
- La migración de espacio de nombres documenta la deshabilitación, la
  instalación, la verificación, la reversión y la limpieza opcional según el
  alcance, incluida la limitación de la reinstalación heredada.
- La protección compartida de Markdown ignora comentarios, código y sintaxis
  escapada en el lint y en la navegación de flujos de trabajo. Los destinos
  válidos entre ángulos y con título se resuelven de forma coherente, y las
  actualizaciones de notas seleccionadas no pueden eludir la navegación de
  catálogos.
- La salida del proveedor se valida y se serializa antes de publicarse. El
  Unicode mal formado recurre a la alternativa de forma segura sin descartar un
  índice listo que no ha cambiado.
- Los catálogos de inicio y de ejemplo conectan sus páginas estructurales. Query
  Quick tiene una salida explícita basada en evidencia y un presupuesto de
  lectura; Save puede redactar un título faltante para el paso de revisión
  existente.
- El lint divide las rutas Markdown codificadas antes de decodificarlas, informa
  del contenido plano de la bóveda que no se analizó, distingue los destinos de
  origen ocultos y entiende las rutas de encabezado admitidas, los enlaces de
  propiedades, las opciones de PDF y las incrustaciones de Base con nombre. Las
  comprobaciones explícitas de páginas generadas validan valores sin imponer un
  esquema en la adopción.
- Las escrituras de registros canónicos respetan el mismo límite de 16 MiB que
  sus lectores. Los diagnósticos de capacidad y la compactación de formato
  revisada conservan las identidades de fuente existentes y las copias de
  seguridad recuperables.
- Los catálogos de Canvas usan `_index.md`; los diarios heredados siguen siendo
  recuperables. Las rutas genéricas de fuentes y preguntas conservan las
  mayúsculas y los espacios del título.
- SessionStart, desactivado por defecto, termina antes de importar la CLI. La
  preferencia por la CLI ahora exige la identidad de la bóveda seleccionada y
  sondas exactas de capacidad de lectura.
- La guía de Defuddle ya no trata un ejecutable externo sin verificar ni una
  entrada HTML local como un mecanismo que hace cumplir los destinos de red
  aprobados.
- Los prefijos de proveedores ligan la reutilización de la caché al modelo y al
  perfil de generación. Haiku 5.5 usa un perfil explícito y acotado de
  pensamiento adaptativo, con un modelo heredado opcional y una alternativa
  segura ante rechazos o truncamientos.

### Añadido

- Evaluación de prompts de Query y Save sin conexión, con hashes de
  instrucciones, contratos de respuesta explícitos y controles negativos. No hace
  solicitudes a proveedores y mantiene el razonamiento controlado de los prompts
  separado de la aceptación operativa de las skills.
- Inspección y aplicación de flujos de trabajo con nombre y por separado para
  Save e Ingest, con una política de catálogos ligada a hashes y resultados
  explícitos de completitud estructural.
- Validación estática de la política de producto de Canvas y comprobaciones de
  texto de Base acotadas con honestidad.
- Evaluación de búsqueda con etiquetas y sin conexión, con recall, MRR,
  denominadores explícitos, fallos retenidos y un fixture multilingüe original.
- Prefijos explícitos de Ollama con modelo instalado, con solicitudes acotadas
  sin proxy, rechazo de redirecciones y verificación previa de modelo local con
  la nube deshabilitada.
- Conciliación fijada con upstream, procedimientos de conformidad nativa, roles
  canónicos de metodología, glosario y recetas de consolidación y coordinación.
- Un control de publicación obligatorio de compatibilidad con los hosts.

### Eliminado

- Generación ambiental de prefijos contextuales con `claude -p`. Sin una API
  configurada explícitamente ni un proveedor local de Ollama, los prefijos siguen
  siendo sintéticos; una CLI de suscripción ya no puede cargar herramientas
  ajenas ni contexto del host.

### Agradecimientos

Pull requests de Ychris12138 (#194), Marcos64s (#199), hphsu (#195),
vinsocci (#63) y miraclemanza (#46), e informes de issues de RoelKluin (#200),
threnard (#193), szrenwei (#191), ppuri2 (#168), cosmos75 (#141) y simonc
(#25) dieron forma a esta versión. [ATTRIBUTION.md](ATTRIBUTION.md) enumera lo
que aportó cada uno.

## [2.2.0] - 2026-09-10

Depuración de pendientes: alcance del lint, recuperación de bloqueos, validación
de hosts, el traslado de `bin/` a `scripts/` para la distribución de plugins en
claude.ai, un único vocabulario de tipos de página, resolución de enlaces que
respeta gitignore y un adaptador de host para ZCode.

### Añadido

- `docs/windows-wsl.md`: una sección "Hooks de Claude Code y python3 en Windows"
  y una fila en la matriz de compatibilidad de plataformas que documentan que los
  hooks requieren un intérprete accesible como `python3` en `PATH`, con notas de
  configuración nativa de Windows para el instalador de python.org y el alias
  sustituto de Microsoft Store.
- `hooks/README.md` y `README.md`: un requisito mínimo declarado de Claude Code
  (una versión actual; el hook de comando en forma exec con `args` y el matcher
  `compact` de `SessionStart` la necesitan), con un enlace al contrato de hooks
  de Claude Code.
- Un flag de CLI repetible `lint --exclude GLOB` y un parámetro equivalente del
  motor `lint_vault(..., exclude=...)` excluyen rutas específicas (por ejemplo,
  una carpeta `wiki/scratchpad/`) del análisis de páginas, de la resolución de
  enlaces, de páginas huérfanas, de frontmatter, de secciones vacías y de
  entradas de índice obsoletas. La misma lista de globs puede definirse del lado
  de la bóveda mediante un arreglo `exclude` (o `exclude_globs` /
  `excluded_paths`) en `.vault-meta/lint.json`, `lint-allowlist.json` o
  `wiki-lint.json`; los patrones de la CLI y los de la configuración de la
  bóveda se combinan. El nuevo recuento `summary.excluded_paths` del informe
  indica cuántos archivos recorridos se descartaron.
- `claude_obsidian/page_schema.py` declara el vocabulario de tipos de página una
  sola vez y separa cada valor válido de `type` del subconjunto que el
  enrutador de metodología puede organizar. `wiki-mode.py` deriva de él los tipos
  que acepta, en lugar de mantener una quinta copia a mano.
- `question` se puede enrutar en los cuatro modos, con un ajuste genérico
  `questions_folder` cuyo valor por defecto es `wiki/questions/`. Ten en cuenta
  la asimetría: solo `generic` lo enruta mediante una clave de carpeta
  configurable; `para` coloca las preguntas bajo
  `resources_folder + "questions/"`, igual que ese modo trata a sus hermanos.
- `wiki-mode.py route` ahora termina con `6` para un tipo de página válido pero
  no enrutable y mantiene `4` para uno desconocido. Son problemas distintos con
  soluciones distintas, de modo que un script que bifurca según `$?` puede
  distinguirlos, y no solo una persona que lee stderr.

### Cambiado

- `ATTRIBUTION.md` ahora reconoce los diseños de los colaboradores detrás de los
  prefijos de tarea del reordenador (PR #77, maartengoet) y de la corrección del
  orden de la alternativa BM25 (PR #62, vinsocci) que adoptó la v2.0.0.
- Los cinco scripts de shell de configuración (`setup-dragonscale.sh`,
  `setup-mode.sh`, `setup-multi-agent.sh`, `setup-retrieve.sh`, `setup-vault.sh`)
  pasaron del directorio `bin/` de nivel superior a `scripts/`. claude.ai rechaza
  cualquier plugin que incluya un directorio `bin/` de nivel superior (está
  reservado para el `PATH` de Bash del plugin); este repositorio nunca dependió
  de ese comportamiento de PATH, así que el único cambio es la ruta de
  invocación; por ejemplo, `bash bin/setup-mode.sh` pasa a ser
  `bash scripts/setup-mode.sh`. Actualiza los scripts locales, alias o CI que
  hagan referencia a las rutas antiguas de `bin/`. `RELEASE_MANIFEST.json` y
  `SHA256SUMS` se actualizan al momento de la publicación.
- Adaptador de host de ZCode (`--host zcode`) para el descubrimiento portátil de
  skills a nivel de usuario en `~/.zcode/skills/`, con un puntero de
  instrucciones `ZCODE.md`.

### Corregido

- `wiki-mode.py route` rechazaba `question`, `comparison`, `overview`, `meta` y
  `fold` (cinco de los nueve tipos de página que documenta WIKI.md) y lo hacía
  con una salida simple sin mensaje, de modo que un error tipográfico y un tipo
  válido pero no enrutable eran indistinguibles. Ahora los rechazos explican qué
  caso aplica.
- La referencia de frontmatter ya no repite una lista de tipos más corta que
  omitía `session` y `fold`, y la skill save ya no nombra los tipos
  `synthesis`/`decision` que ninguna otra fuente declara.
- El `.obsidian/app.json` de la bóveda con estructura inicial ahora fija el ajuste
  "Nuevo formato de enlace" de Obsidian en `absolute`. Antes se dejaba sin
  definir, con lo que se aplicaba el valor propio de Obsidian, "Ruta más corta
  cuando sea posible". Los enlaces creados desde la interfaz de Obsidian con ese
  valor se resuelven bien dentro de Obsidian, pero no se pueden resolver (o,
  cuando un segundo archivo comparte nombre base, se resuelven mal en silencio)
  en el resto de las partes del producto que tocan enlaces, y todas resuelven los
  wikilinks por ruta exacta relativa a la bóveda, sin resolución aproximada: los
  scripts de resincronización, el enlazador de terminología y la detección de
  enlaces rotos o ambiguos del lint.
- El `.gitignore` de la raíz del repositorio ahora ignora `.mcp.json`, en
  coherencia con la plantilla de bóveda y la guía de instalación, que tratan una
  configuración MCP de alcance de proyecto como un posible portador de
  credenciales. Sugerido por el PR #44.
- `stop_status` ahora lee diarios de transacciones hasta el límite de JSON de
  ejecución de 8 MiB que ya tiene el paquete, de modo que los diarios válidos
  grandes no se informan por error como ilegibles. Los diarios no seguros o
  ilegibles ahora requieren inspección manual, y el consejo de recuperación se
  limita a los diarios con un estado recuperable reconocido.
- `checkpoint` ahora respeta los valores falsos de Git para `core.filemode`. Git
  ignora las diferencias del bit ejecutable del árbol de trabajo en ese modo, así
  que el punto de control mantiene la verificación estricta del contenido y omite la
  comparación del modo ejecutable.
- Las respuestas de prefijos contextuales de Anthropic ahora tienen un tope de
  lectura de 256 KiB además del tiempo de espera existente, lo que impide que una
  respuesta demasiado grande consuma memoria sin límite. Los fallos de lectura
  del cuerpo de la respuesta, el UTF-8 no válido, el anidamiento excesivo de JSON
  y las formas de respuesta mal formadas fallan en modo cerrado.
- `tests/test_contextual_prefix.py` y `tests/test_wiki_mode.py` ya no fallan en
  Windows nativo antes de terminar de ejecutar sus aserciones. Ambos imprimen `→`
  en las etiquetas de las pruebas; la codificación de consola predeterminada de
  Windows, `cp1252`, lanzaba `UnicodeEncodeError` en la primera impresión de ese
  tipo. Ahora ambos archivos reconfiguran stdout a UTF-8 al iniciar, con una
  protección para que un ejecutor con salida capturada o redirigida y sin un
  stdout capaz de `reconfigure` siga funcionando.
- El validador de hosts públicos de `capture.py` ahora rechaza las grafías de
  loopback en hexadecimal con puntos, octal con puntos y forma corta
  (`0x7f.0.0.1`, `0177.0.0.1`, `127.1`, `0x7f.0x0.0x0.0x1`) que
  `ipaddress.ip_address()` no analiza y que antes solo recibían una comprobación
  de etiqueta única. Replica el rechazo existente de etiquetas numéricas en el
  canonicalizador de URL del registro de fuentes.
- Doce archivos `SKILL.md` que enlazan a `skills/wiki/references/` ahora indican
  que un enlace `../wiki/references/` se resuelve respecto del directorio propio
  de la skill dentro de `$PRODUCT_ROOT`, nunca respecto del directorio `wiki/` de
  la bóveda seleccionada. La validación del paquete ahora señala cualquier enlace
  de este tipo al que le falte esa oración ancla.
- Por defecto, el lint ya no recorre los directorios con prefijo de punto (los
  archivos de ingesta `.raw/`, los worktrees de agentes `.claude/`, la `.trash/`
  propia de Obsidian y similares), igual que el indexador de Obsidian. Antes, una
  página duplicada o archivada bajo una carpeta con prefijo de punto se volvía un
  candidato real para la resolución de enlaces, y convertía un único
  `[[Wikilink]]` sano en un hallazgo falso de `ambiguous_targets` (y, en páginas
  de índice, de `stale_index_entries`).
- `--force-stale-lock` ahora puede retirar un bloqueo de modificación o un
  bloqueo de la cola de captura más reciente que `--stale-after` cuando se
  confirma que el PID del propietario registrado ya no existe en el mismo host.
  Sigue sin retirar nunca el bloqueo de un propietario activo del mismo host antes
  de que transcurra `--stale-after` y sigue manteniendo el control de antigüedad
  para un propietario de otro host o que no se pueda resolver. Los dos textos de
  ayuda de `recover` ahora lo describen con precisión.
- La lectura de los archivos de ejecución de las transacciones ahora tolera un
  cambio externo que solo toca mtime (por ejemplo, un cliente de sincronización
  que actualiza metadatos): vuelve a leer una vez y acepta el contenido solo si
  los bytes son idénticos a los de la primera lectura. Cualquier cambio de
  tamaño, inodo, dispositivo o modo, y cualquier cambio de contenido durante la
  lectura, sigue fallando en modo cerrado con `CORRUPT_RUNTIME_STATE`.
- La resolución de enlaces del lint ya no informa que un wikilink es ambiguo
  cuando los candidatos adicionales son archivos ignorados por gitignore (por
  ejemplo, un binario compilado cuyo nombre coincide con una página, como
  `bin/env8oy` junto a `wiki/projects/env8oy.md`). Un nuevo evaluador de
  `.gitignore` en Python puro (`claude_obsidian/gitignore.py`) lee solo los
  archivos `.gitignore` dentro de la raíz de la bóveda (nunca
  `.git/info/exclude`, las exclusiones globales ni un subproceso de `git`), de
  modo que los informes siguen siendo deterministas y sin procesos. Los archivos
  ignorados por gitignore siguen siendo destinos de enlace válidos cuando son el
  único candidato, así que no se introducen nuevos enlaces rotos; la ambigüedad
  entre candidatos que solo están ignorados por gitignore sigue informándose.
  Esto desbloquea las ejecuciones de `checkpoint` que antes fallaban con
  `LINT_FAILED` siempre que existía un artefacto de compilación.

## [2.1.1] - 2026-08-26

Seguridad en la migración heredada y una guía de compatibilidad con Windows y WSL
más clara.

### Añadido

- `docs/windows-wsl.md`: matriz de compatibilidad de plataformas y solución de
  problemas de WSL para usuarios de Windows nativo, que cubre el flujo de
  diagnóstico de Microsoft para bloqueos no confirmados de `wsl --status`, la
  vinculación del hash de aprobación al entorno y los requisitos de identidad del
  sistema de archivos. Se enlaza desde el README, la guía de instalación, la guía
  de la bóveda compuesta y la referencia de transacciones de la skill wiki.

### Cambiado

- El mensaje de rechazo `UNSUPPORTED_PLATFORM` ahora remite a
  `docs/windows-wsl.md` para los usuarios cuya configuración de WSL falla por sí
  misma.
- La solución de problemas de Windows y WSL ahora encamina los bloqueos no
  confirmados por el flujo de diagnóstico de Microsoft sin afirmar una causa no
  respaldada.

### Corregido

- La migración y la adopción heredadas ya no fallan cuando una clave de fuente del
  manifiesto es una etiqueta de lote válida y no un archivo. Las etiquetas sin
  resolver se conservan como fuentes manuales sin revisar, sin inventar
  asignaciones de contenido ni hashes. Aplicar ahora rechaza una migración
  revisada si el estado del archivo de un localizador heredado cambia o deja de
  ser seguro antes de que la transacción escriba.
- La migración y la adopción mantienen las observaciones de fuentes de solo
  lectura separadas del límite de recuperación de 1,024 escrituras, y conservan
  los manifiestos heredados válidos con conjuntos de fuentes más grandes.
- Los fixtures de publicación y de punto de control respaldados por Git ahora ignoran
  los hooks de todo el equipo y la configuración de firma de commits, de modo que
  el conjunto de pruebas hermético se mantiene sin conexión y determinista.

## [2.1.0] - 2026-07-31

Compatibilidad con Windows nativo.

### Corregido

- Windows nativo ya no falla con `AttributeError: os.O_DIRECTORY` en cada comando
  de la bóveda. La inspección de solo lectura y las simulaciones
  (`transaction inspect`, vistas previas de `migrate`/`init`/`adopt`/`capture`)
  ahora funcionan de forma nativa, con comprobaciones de seguridad equivalentes
  reales: auditoría de alias por plegado de mayúsculas basada en rutas,
  identidad de la bóveda basada en lstat y rechazo de enlaces simbólicos y de
  uniones (junctions).
- Las lecturas de archivos en el núcleo de transacciones ahora fuerzan el modo
  binario (`O_BINARY`), de modo que el contenido con CRLF se calcula en hash byte
  a byte en Windows en lugar de producir falsos fallos
  `CONTENT_HASH_MISMATCH`/`EXPECTED_HASH_MISMATCH`.
- La salida de la CLI es siempre UTF-8, lo que corrige los fallos
  `UnicodeEncodeError` al redirigir una salida con títulos no ASCII en Windows
  (consolas cp1252).
- La búsqueda ya no devuelve cero resultados para bóvedas con finales de línea
  CRLF: el fragmentador, el índice y el buscador ahora calculan el hash de los
  cuerpos de página de forma idéntica byte a byte (antes, la normalización de
  saltos de línea de `read_text` hacía que cada fragmento pareciera obsoleto).
- Con un bloqueo de modificación activo, una bóveda cuyo nombre en disco difiere
  solo en mayúsculas y minúsculas de la grafía usada en la línea de comandos ya
  no se informa por error como su propio alias portátil en sistemas de archivos
  que no distinguen mayúsculas de minúsculas (APFS; la capa de bloqueo nunca se
  ejecuta en Windows nativo); el objeto de bóveda fijado por descriptor se
  reconoce como sí mismo. La auditoría en el momento de la inspección conserva el
  comportamiento más estricto ya publicado, porque una raíz de init ausente en un
  volumen que no distingue mayúsculas de minúsculas no puede distinguirse de un
  hermano ajeno.

### Cambiado

- La modificación de la bóveda en hosts sin confinamiento por descriptor de
  directorio (Windows nativo) se rechaza antes de cualquier efecto secundario con
  un nuevo error de validación `UNSUPPORTED_PLATFORM` (salida 2, antes un
  `LOCK_FAILED` genérico con salida 1 o un traceback), y `init --apply` ya no crea
  un directorio de bóveda vacío abandonado en las plataformas rechazadas.
- Los nuevos destinos de escritura de las transacciones se validan en todas las
  plataformas con las reglas de sistemas de archivos portátiles: los nombres de
  dispositivo reservados de Windows (`CON`, `NUL`, ...), los caracteres `:<>|?*"`
  y los puntos o espacios finales se rechazan con `UNPORTABLE_WRITE_PATH`, de
  modo que un plan aprobado signifique lo mismo en todas partes. Las lecturas, la
  indexación de la búsqueda y la recuperación del diario de archivos preexistentes
  con esos nombres no se ven afectadas de forma intencional.
- Los recorridos de rutas en modo degradado ahora rechazan las uniones de
  directorio y los puntos de montaje de Windows, además de los enlaces simbólicos.
- Los bits de permisos de archivo que alimentan los hashes de los planes se
  normalizan a `0o644` en Windows, lo que mantiene determinista la salida de
  inspect.
- Se añadió un `.gitattributes` que desactiva la traducción de finales de línea
  para que las copias de trabajo tengan el mismo hash en todas las plataformas.
- CI incorporó un trabajo `windows-smoke` que ejercita la superficie portátil de
  Python y el nuevo conjunto de compatibilidad con Windows en `windows-latest`.
- Se reemplazó la imagen principal animada del README por la portada PNG estática
  seleccionada, conservando el estilo orbital cálido.

## [2.0.0] - 2026-07-30

Refundación de la confiabilidad y la evidencia.

### Añadido

- Núcleo `claude_obsidian` de biblioteca estándar con selección de bóveda que
  falla en modo cerrado, transacciones de operación recuperables, recuperación
  tras fallos, manifiestos exactos de rutas modificadas y puntos de control
  explícitos de Git.
- Lint determinista de Obsidian, contratos de producto y de capacidades,
  validación portátil de paquetes, registros de fuentes y de afirmaciones, y
  migración heredada aditiva.
- Comandos `init`, `adopt`, configuración de metodología, captura de fuentes,
  configuración de extensiones y construcción y auditoría de artefactos públicos,
  todos con simulación primero.
- Captura direccionable por contenido, sin conexión por defecto, y colas
  duraderas. La compatibilidad con imágenes, PDF y EPUB es solo de metadatos, a
  menos que se apruebe explícitamente un adaptador configurado por separado.
- Constructor reproducible de ZIP desde Git limpio, con manifiestos, sumas de
  verificación, modos ejecutables deterministas y defensas contra secretos, rutas
  privadas, estado de bóvedas en uso, enlaces simbólicos, recorrido de rutas,
  colisiones, binarios sin revisar y archivos hostiles.
- Generación del marketplace solo en el artefacto: el código fuente de desarrollo
  conserva una plantilla de catálogo revisada en `config/`; la construcción de la
  publicación la inyecta únicamente en la raíz limpia de distribución y verifica
  que el árbol promovido pueda reconstruirse.
- Plantillas y bóveda de ejemplo deterministas, CI en Linux y macOS, pruebas de
  aislamiento de raíces, cobertura de concurrencia y de inyección de fallos, y
  descubrimiento automático de pruebas.
- Cobertura de regresión adversaria para escapes mediante enlaces simbólicos e
  intercambio de directorios padre, aprobaciones obsoletas, URL de credenciales
  firmadas, violaciones de procedencia, estado en el área de preparación de Git,
  interrupción de puntos de control y ventanas de finalización de transacciones.

### Cambiado

- Se reconstruyó el README en torno a la promesa del producto, el ciclo de
  acumulación, ejemplos reales de bóvedas, una incorporación concisa, la
  arquitectura de confianza y límites honestos de capacidad.
- Se adoptó el sistema de portadas orbitales cálidas, se añadió la portada PNG
  estática seleccionada sin metadatos, se conservaron las capturas de pantalla de
  Obsidian y se alinearon al nuevo estilo los diagramas de arquitectura SVG
  autónomos.
- Las 15 skills ahora usan el frontmatter canónico de Agent Skills de dos campos
  y un único contrato de operación neutral respecto del host.
- Los agentes de ingesta e investigación en paralelo solo producen borradores. Un
  único orquestador inspecciona y aplica la operación de conocimiento completa.
- La consulta y el lint son de solo lectura. La persistencia y las reparaciones
  son operaciones revisadas por separado.
- Los hooks de Claude son adaptadores acotados de SessionStart y Stop. Stop
  informa del estado de recuperación; la inyección de contexto de SessionStart
  requiere la activación explícita `CLAUDE_OBSIDIAN_SESSION_CONTEXT=1`. Ninguno
  modifica el conocimiento ni Git.
- Los auxiliares de configuración e instalación funcionan por defecto como vistas
  previas, usan las bóvedas de usuario seleccionadas, evitan el estado de la caché
  de plugins y conservan la configuración existente.
- La instalación portátil crea enlaces por skill directamente detectables en la
  raíz de skills vigente de cada host, y las skills ejecutables resuelven los
  auxiliares del producto mediante rutas absolutas de instalación y no mediante
  el directorio de trabajo de la bóveda del usuario.
- La búsqueda ahora elimina fragmentos obsoletos, invalida los índices derivados,
  deduplica antes del top-K, confina las rutas, usa prefijos de Nomic específicos
  de cada tarea y restaura el resultado completo de BM25 cuando no se puede
  confiar en el reordenamiento. El tamaño de la consulta y el número de
  resultados están acotados; los límites no válidos y las consultas demasiado
  grandes fallan con errores de uso con código distinto de cero y con
  indicaciones accionables.
- La búsqueda CJK ahora normaliza la entrada Unicode e indexa n-gramas de
  caracteres acotados para que las consultas en japonés, chino, coreano,
  bopomofo y de ancho mixto puedan coincidir con documentos más largos; los
  índices derivados heredados fallan en modo cerrado con indicaciones para
  reconstruirlos.
- El reordenamiento semántico opcional usa por defecto el modelo multilingüe
  Nomic v2 MoE, emplea la API de embeddings de entrada única vigente de Ollama,
  admite la selección explícita de modelo con semántica exacta de etiquetas y
  conserva el orden determinista de BM25 cuando el modelo local seleccionado no
  está disponible.
- El análisis de publicaciones públicas rechaza las direcciones de correo
  personales reconocibles y solo conserva dominios de ejemplo reservados e
  identidades noreply generadas por GitHub para fixtures y procedencia; los
  localizadores de clonación por SSH y los especificadores numéricos de versión
  de paquetes no se clasifican por error como direcciones de correo.
- El código fuente del producto, las bóvedas de usuario, las plantillas
  deterministas y los artefactos públicos son roles separados y explícitos.
- Las referencias de configuración distribuibles ahora siguen los mismos límites
  de transacción, privacidad, revisión de plugins, TLS y evidencia que las skills.
- Los flujos de simulación y aplicación están ligados a hashes de plan canónicos
  y exactos, específicos de cada bóveda. Los destinos de las transacciones usan
  escrituras y eliminaciones relativas a la bóveda sin seguir enlaces simbólicos,
  reservan los espacios de nombres del producto y de ejecución, y hacen cumplir
  los alcances de flujo de trabajo declarados; los contratos de procedencia se
  hacen cumplir durante inspect, apply, lint y checkpoint.
- Los puntos de control explícitos ahora construyen y verifican objetos de Git
  mediante un índice temporal, actualizan las referencias por comparar e
  intercambiar (compare-and-swap) y se recuperan a partir de un registro pendiente
  duradero sin consumir estado ajeno en el área de preparación ni marcado con
  intent-to-add. El contenido y los modos ejecutables deben coincidir ambos con el
  resultado de la transacción.
- La preparación de las capacidades ahora distingue los flujos de trabajo
  configurados de la verificación conductual genuina; las comprobaciones de
  esquema y las autocomprobaciones no pueden promover una capacidad.
- Las identidades de procedencia ahora unifican las grafías de URL equivalentes
  según RFC (IPv6, IDN, Unicode/IRI, puerto por defecto, segmentos de punto y
  codificación porcentual) antes de contar la independencia de las fuentes; las
  formas mal formadas o no escalares fallan en modo cerrado.
- El enrutamiento de Zettelkasten ahora combina su prefijo UTC en microsegundos
  con un nonce UUIDv4, lo que evita colisiones entre vistas previas rápidas o
  concurrentes sin escrituras de asignador. Los metadatos de formato heredados se
  normalizan mediante cambios de modo revisados, los componentes UTF-8 demasiado
  largos reciben un sufijo de hash dentro del mínimo de portabilidad de 255 bytes
  y los nombres de archivo existentes que solo llevan marca de tiempo siguen
  siendo válidos.

### Eliminado

- Los espejos duplicados de comandos y el comportamiento genérico de PostToolUse
  o PostCompact.
- Las escrituras compartidas directas, los commits automáticos de Git y los
  bloqueos por archivo de la ruta de modificación admitida.
- Las afirmaciones comparativas, de rendimiento y de capacidad sin respaldo, que
  se quitan de la documentación vigente del producto.
- Los fragmentos de CSS de Obsidian de la bóveda de contribuidores de la raíz,
  que ya no se incluyen en el artefacto público; se mantiene el fragmento de
  plantilla determinista propiedad del proyecto.

### Compatibilidad

- Las bóvedas existentes siguen siendo legibles. La migración es aditiva,
  idempotente y conserva el manifiesto raw heredado byte a byte.
- `scripts/wiki-lock.sh` sigue siendo únicamente un auxiliar de compatibilidad
  obsoleto de la v1.
- Las herramientas del producto nunca publican, hacen push, etiquetan ni modifican
  el estado público de colaboración sin la aprobación del propietario.

## [1.9.2] - 2026-05-27

- Se añadieron estadísticas locales acotadas de la caché de prompts a las
  llamadas a la API de prefijos contextuales aprobadas explícitamente.
- Se endureció el manejo de rutas explícitas y se ampliaron las pruebas herméticas
  de prefijos contextuales.

## [1.9.1] - 2026-05-18

- Se endurecieron el confinamiento de rutas de bloqueo heredadas, las sondas de
  transporte, las advertencias de caché y el consentimiento para Ollama remoto.
- Se añadió documentación del modelo de amenazas de un solo inquilino orientada a
  operadores.

## [1.9.0] - 2026-05-18

- Se añadió la skill de razonamiento de 10 etapas OBSERVAR, OBSERVAR, ESCUCHAR,
  PENSAR, CONECTAR, CONECTAR, SENTIR, ACEPTAR, CREAR, CRECER.
- Se añadieron las bases del repositorio para contribuciones, seguridad, issues,
  pull requests y CI.

## [1.8.2] - 2026-05-18

- Se conservaron las sustituciones manuales de transporte y se endurecieron el
  enrutamiento de modos, la sanitización de entradas y la selección local de
  bóveda.
- Se ampliaron las pruebas del verificador y de la búsqueda.

## [1.8.0] - 2026-05-17

- Se añadieron modos de metodología opcionales: Generic, LYT, PARA y Zettelkasten.
- Se añadieron el enrutamiento determinista de rutas y la configuración no
  destructiva de modos.

## [1.7.2] - 2026-05-17

- Se añadieron la tokenización BM25 con soporte de Unicode y el endurecimiento
  ante fallos de la búsqueda.
- Se mejoraron el bloqueo de la caché, el informe de progreso y los diagnósticos
  de entradas no válidas.

## [1.7.1] - 2026-05-17

- Se hizo explícita la salida de red de los prefijos contextuales y se añadió un
  rol de verificador de solo lectura.
- Se endurecieron el manejo de JSON del transporte y la recuperación ante fallos
  de la búsqueda heredada.

## [1.7.0] - 2026-05-17

- Se añadieron búsqueda contextual opcional, BM25, reordenamiento local,
  detección de transporte y una capa de compatibilidad heredada para varios
  escritores.
- Se añadieron las skills `wiki-cli` y `wiki-retrieve`.

## [1.6.0] - 2026-04-24

- Se añadieron la skill autoresearch, de activación voluntaria y que empieza por
  los límites, y su evaluador determinista de grafos.

## [1.5.1] - 2026-04-24

- Se endureció el confinamiento de rutas de la bóveda y se alinearon los
  metadatos de despliegue de DragonScale.

## [1.5.0] - 2026-04-24

- Se añadieron prototipos de consolidación, dirección determinista y teselado
  semántico de activación voluntaria.
- Se añadieron el arnés de pruebas inicial y los auxiliares de configuración de
  extensiones.

## [1.4.3] - prior

- El historial anterior del proyecto sigue disponible en Git.
