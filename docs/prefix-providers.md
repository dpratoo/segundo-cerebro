# Proveedores opcionales de prefijos contextuales

Los prefijos sintéticos siguen siendo la opción por defecto. Haz una vista
previa con `--peek`; usa `--no-llm` para que una construcción sea determinista y
no dependa de ningún proveedor. Elegir un proveedor solo cambia cachés derivadas
y requiere una construcción explícita. Las páginas canónicas permanecen sin
cambios.

## Un modelo local de Ollama instalado

Pasa `--local-ollama --ollama-model name:tag` a contextual-prefix.py. El
adaptador nunca inicia un servidor, descarga un modelo ni recurre a un proveedor
en la nube. Antes de transmitir texto de páginas, exige una respuesta de estado
con la nube desactivada, la etiqueta y el digest exactos de un modelo instalado,
y metadatos del modelo local. Los servidores más antiguos que no tienen estos
campos recurren a prefijos sintéticos. Un digest de modelo que cambia invalida
los prefijos en caché en la siguiente construcción explícita.

Cuando esa verificación previa no está disponible, por ejemplo durante una
interrupción transitoria, la causa se informa una sola vez para la operación y
no se envía texto de páginas. Los registros existentes producidos por el mismo
endpoint y modelo con la revisión actual del prompt se conservan para los
fragmentos sin cambios, porque su digest no se puede volver a comprobar hasta
que el servidor regrese. Solo los fragmentos nuevos o modificados reciben un
prefijo sintético. Si ningún fragmento cambia, los registros de fragmentos y el
índice BM25 listo permanecen idénticos byte a byte.

El endpoint por defecto es el loopback numérico `127.0.0.1`. El nombre de host
exacto `localhost` se normaliza a `127.0.0.1` antes de cualquier solicitud, y el
literal `::1` sigue disponible. Esto evita que el modo local dependa de la
configuración del resolvedor del host. Un endpoint explícito que no sea loopback
requiere además la aprobación del usuario y `--allow-remote-ollama`. Elige HTTPS
para un servidor remoto cuando el contenido de las páginas necesite cifrado de
transporte. La validación estándar del nombre de host del certificado se aplica
al endpoint numérico normalizado, de modo que un certificado solo para
`localhost` no cubre `https://127.0.0.1`. Los proxies y las redirecciones están
desactivados. Las solicitudes y las respuestas JSON están acotadas, igual que la
salida y los tiempos de espera. Cada tiempo de espera es un único plazo de reloj
para toda la solicitud: conexión, carga, encabezados de la respuesta y cada
lectura del cuerpo. Un servidor que envía los bytes con cuentagotas no puede
ampliarlo. Las respuestas se analizan de forma estricta, y una clave de objeto
duplicada a cualquier profundidad rechaza la respuesta.
Las respuestas no compatibles, el rechazo, el truncamiento y una identidad de
modelo que no coincide producen prefijos sintéticos y abren el circuito de la
operación. Los fragmentos y las páginas posteriores recurren entonces a la
alternativa sin otra solicitud de generación. Un servidor proporcionado por el
usuario puede falsear su configuración; la verificación previa no certifica la
máquina remota.

Los endpoints opcionales de embeddings de Ollama que usan el reordenamiento y el
teselado semántico aplican la misma normalización exacta de `localhost` a
`127.0.0.1` antes de su primera solicitud de transporte. Conservan un puerto y
una ruta base explícitos, mantienen un `::1` literal y conservan el requisito
aparte de consentimiento para endpoints remotos.
Antes de cualquier trabajo con consultas, páginas, fragmentos o la caché de
embeddings, todos los que llaman a Ollama exigen que el estado del servidor
informe `cloud.disabled` con el valor booleano `true`.
También exigen un modelo instalado seleccionado con un digest válido y un
`model_info` local no vacío. Las etiquetas de la nube, los campos de modelo
remoto, una identidad mal formada y los digests de alias en conflicto no superan
esta prueba. Los campos remotos son decisivos en las respuestas de estado y de
metadatos del modelo, en la envoltura de la lista de modelos y en las entradas
de la lista del modelo seleccionado o de su alias permitido. Otro modelo de la
nube instalado nunca recibe la solicitud y no bloquea un modelo local. Una
etiqueta explícita coincide de forma exacta. Un modelo de embeddings sin
etiqueta coincide solo con su nombre exacto o con `:latest`, y se prefiere el
nombre exacto. `--allow-remote-ollama` aprueba solo el endpoint del servidor. No
aprueba la delegación a la nube por parte de ese servidor.
Cada GET y POST de embeddings desactiva los proxies del entorno, rechaza las
redirecciones, exige que la URL final de la respuesta coincida con la URL
solicitada y lee una respuesta JSON acotada dentro del mismo plazo de reloj por
solicitud y con el mismo análisis estricto de claves duplicadas. Una línea de
estado HTTP mal formada u otro error de protocolo se trata como un servidor no
disponible: el reordenamiento recurre al orden de BM25 y el teselado termina con
el código 10, o con el 12 una vez iniciada la prueba local. El reordenamiento
valida una consulta no vacía de hasta 8,000 caracteres normalizados con NFKC y
como máximo 1,000 candidatos de objeto con rutas relativas seguras y
puntuaciones finitas, antes de cualquier trabajo con el modelo, el endpoint, la
caché o los embeddings. El teselado semántico valida la versión 1 del esquema de
umbrales y bandas finitas que cumplan `0 <= review < error <= 1`, antes de
sondear proveedores o de leer y escribir cachés.
Una entrada mal formada termina por la interfaz controlada documentada y no
envía a Ollama ninguna consulta, candidato ni cuerpo de página.
Las respuestas de embeddings y los vectores en la caché del teselado semántico
deben ser listas acotadas de números finitos que no sean booleanos, con una
dimensión consistente por modelo. Los documentos de caché mal formados terminan
según el contrato de corrupción de la caché, antes de cualquier publicación de
la caché. Las claves de la caché del reordenamiento incluyen el digest
verificado del modelo. La versión 2 del esquema de la caché del teselado
semántico vincula las entradas reutilizables con el nombre y el digest
resueltos del modelo. Una caché válida de la versión 1 se trata como un fallo de
caché, mientras que una caché heredada mal formada sigue siendo corrupción. El
primer fallo de embedding del teselado semántico, ya sea un error HTTP, una
identidad remota en la respuesta o un cambio de dimensión, abre un circuito
durante la ejecución: no se envía ningún otro cuerpo de página, y los vectores
en caché siguen aportando al informe. Un fallo parcial o total de embeddings
conserva la caché anterior, imprime un informe provisional incompleto y termina
con el código 12.
Un JSON de fragmento de reordenamiento mal formado, incluido un contenido
seleccionado que no es texto, conserva todo el conjunto de candidatos mediante
la alternativa documentada de BM25.
Los límites de conversión o de anidamiento del analizador JSON siguen los mismos
contratos de error o de alternativa para la caché, los umbrales y los candidatos
que cualquier otro JSON mal formado. No escapan como excepciones de análisis sin
procesar.

El contrato de origen se revisó contra la revisión
`d1ed3fd13ac73f60cff00bbead8af24a68c4200d` de Ollama, incluidos su
[manejador de estado](https://github.com/ollama/ollama/blob/d1ed3fd13ac73f60cff00bbead8af24a68c4200d/server/routes.go)
y sus [tipos de respuesta](https://github.com/ollama/ollama/blob/d1ed3fd13ac73f60cff00bbead8af24a68c4200d/api/types.go),
comprobados el 2026-10-17. Las pruebas de protocolo con simulaciones son
independientes de la compatibilidad con un servidor real. No se ha establecido
una versión publicada mínima de Ollama.

## Un proveedor en la nube aprobado de forma explícita

`--allow-egress` permite solicitudes directas a la API de Anthropic cuando
`ANTHROPIC_API_KEY` está presente. Una clave de API nunca cuenta como
consentimiento. Indica qué proveedor recibirá el cuerpo de las páginas
seleccionadas antes de una construcción aprobada.

La API usa por defecto `--anthropic-model claude-haiku-5-5`, con esfuerzo bajo,
razonamiento adaptativo y un presupuesto de salida acotado de 2,048 tokens. El
perfil heredado explícito es `--anthropic-model claude-haiku-4-5-20251001`. Los
identificadores de modelo no compatibles se rechazan. Una salida rechazada,
truncada, vacía o inutilizable recurre directamente a un prefijo sintético y
abre el circuito de la operación. Los fragmentos y las páginas restantes usan
prefijos sintéticos sin repetir una solicitud de generación fallida. El modo
local de Ollama nunca elige la API.

Los cuerpos de las solicitudes de generación tienen tres límites de operación
configurables. Los valores por defecto son 128 solicitudes, 16,777,216 bytes
serializados de cuerpo de solicitud para toda la operación y 1,048,576 bytes
serializados en UTF-8 de cuerpo de solicitud para una sola solicitud. Usa
`--provider-max-requests`, `--provider-max-bytes` y
`--provider-max-request-bytes` para cambiar esos valores dentro de sus topes
máximos. Los topes máximos son 512 solicitudes, 134,217,728 bytes por operación
y 4,194,304 bytes para una sola solicitud.
Ollama en modo local mantiene su límite menor de 131,072 bytes por solicitud. El
conjunto completo de solicitudes planificadas para una página se mide antes de
la primera llamada de generación de esa página. Una página que no cabe en el
conteo o en el presupuesto de bytes restante usa prefijos sintéticos sin
ejecución parcial del proveedor. Los conteos y los bytes se comparten entre
todas las páginas seleccionadas en un mismo comando. Las rutas sintéticas y de
vista previa no consumen nada de este presupuesto de generación, incluidas las
ejecuciones explícitas con `--no-llm`.

El mínimo de 512 tokens de la caché depende del modelo. La estimación por conteo
de caracteres es solo una heurística; las lecturas y escrituras reales de la
caché requieren telemetría del proveedor. Cambiar el modelo o el perfil de
generación actualiza los prefijos derivados en la siguiente construcción
explícita. Estos perfiles se comprobaron contra la
[guía de modelos](https://platform.claude.com/docs/en/models/haiku-5-5/migration-guide)
y la [guía de caché](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
vigentes el 2026-10-17. Las pruebas de carga útil con simulaciones establecen el
comportamiento de las solicitudes, no la calidad de un modelo real, el ahorro de
caché ni la facturación.

El nivel de generación con la CLI de Claude del entorno se eliminó. Ningún
subproceso `claude -p`, alternativa por suscripción, herramientas del host,
hooks ni configuración del host cargada participa en la generación de prefijos.
Sin una clave de API utilizable ni un proveedor local de Ollama seleccionado, el
resultado es sintético. Los registros antiguos de `claude-cli` y los de
revisiones anteriores del prompt se regeneran en la siguiente construcción
explícita, incluso cuando su texto coincida por casualidad con el resultado
sintético. Nunca se conservan como una alternativa segura equivalente.

## Envolturas del origen y validación de la salida

Cada página actual de la wiki se decodifica como UTF-8 estricto durante la
verificación previa de direcciones, antes de la verificación previa opcional del
proveedor, de la construcción de la envoltura de la página, de las solicitudes
al proveedor y de cualquier modificación de la caché derivada y del índice. Un
UTF-8 mal formado termina con el error controlado de página y conserva los
fragmentos y los bytes del índice existentes. El punto de entrada directo de
procesamiento de una sola página aplica la misma decodificación estricta antes
de inspeccionar el estado derivado.

Ambos generadores usan la misma política de confianza del sistema. Cada página
procesada crea un identificador aleatorio nuevo, compartido por todas las
etiquetas de página y de fragmento de esa página. El identificador se nombra en
la instrucción de sistema de cada solicitud. Los títulos, los cuerpos y los
fragmentos se codifican como JSON y se escapan como HTML dentro de esas
etiquetas, de modo que las comillas incrustadas, las etiquetas de cierre
coincidentes, los caracteres de control y el texto de roles falsos siguen siendo
datos. Los identificadores de solicitud no entran en el perfil de prefijos
derivado, así que la aleatoriedad por sí sola nunca causa una reconstrucción.
Reutilizar el mismo identificador dentro de una página mantiene estables, byte a
byte, sus bloques de sistema y de página entre las solicitudes de fragmentos. Se
conservan los marcadores de elegibilidad, pero solo la telemetría del proveedor
establece el uso real de la caché.

Una respuesta del modelo debe poder codificarse en UTF-8, no estar vacía, ser de
una sola línea, tener como máximo 34 palabras separadas por espacios y como
máximo 280 caracteres Unicode. El límite de caracteres también se aplica a la
escritura sin espacios. La validación admite escrituras no latinas y los
caracteres de unión que usan algunos idiomas. Rechaza los caracteres de
control, los separadores de línea, los controles de formato direccional y la
sintaxis de marcado. Las respuestas no válidas recurren a la alternativa en su
totalidad; el adaptador nunca conserva en silencio la primera línea ni trunca
una respuesta no válida del modelo. El prefijo sintético determinista conserva
su propio límite aparte de 1,000 caracteres.

Cada registro de reemplazo de una página se serializa antes de invalidar su
índice BM25 listo. Por lo tanto, un fallo de codificación conserva los
fragmentos y el índice anteriores de esa página. Si un proveedor falla y su
alternativa sintética coincide exactamente con una generación existente que
tiene el perfil sintético seguro vigente y una identidad de origen coincidente,
el fragmento original y el índice listo permanecen idénticos byte a byte. Los
registros de alternativa identifican el proveedor efectivo como sintético. Un
conjunto de fragmentos modificado igualmente invalida el índice anterior antes
de la publicación y requiere la reconstrucción explícita habitual de BM25. Los
fallos de publicación en el sistema de archivos posteriores a la invalidación
también dejan la búsqueda no disponible hasta que se reconstruya, lo que evita
una lectura de generaciones mezcladas.

Un fragmento existente se omite solo cuando su esquema, los hashes de origen, el
texto sin procesar, el conteo de caracteres, el texto contextualizado, el
proveedor efectivo y el perfil de prefijos completo concuerdan con la página
actual y con el perfil de generación solicitado. Los esquemas desconocidos, las
claves JSON duplicadas, los valores JSON que no son objetos y los registros
derivados mal formados o internamente inconsistentes se regeneran. Un registro
sintético también debe coincidir con el prefijo determinista recalculado a
partir de la página y el fragmento actuales.

Estas comprobaciones establecen límites estructurales y una salida acotada, no
la corrección semántica de las oraciones, la detección de instrucciones ni la
resistencia a la inyección de prompts. Las pruebas usan respuestas simuladas y
bóvedas temporales; el comportamiento de un proveedor real, la calidad de la
búsqueda y la aceptación adversaria del modelo siguen sin verificarse.
