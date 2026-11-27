# Recetas de glosario citado y de consolidación

Estos son usos acotados de los flujos existentes de Ingesta y de Guardado. No
agregan ninguna acción en segundo plano, ninguna skill nueva ni ninguna fusión
automática. Selecciona primero la bóveda y el presupuesto de fuentes. Lee
[provenance.md](provenance.md) y
[operation-transactions.md](operation-transactions.md).

## Glosario a partir de fuentes

1. Busca los conceptos y alias existentes antes de proponer términos. Enumera las
   rutas de las fuentes y los encabezados, bloques o rangos de líneas exactos que
   respaldan cada definición.
2. Redacta una definición por cada significado, en el dominio y el idioma de la
   fuente. Separa una definición de la fuente de una simplificación editorial.
   Conserva las definiciones en conflicto con sus alcances; no las reduzcas a un
   consenso.
3. Usa una página `concept` o una sección de glosario acotada. Agrega alias solo
   para nombres realmente equivalentes y enlaza las páginas de fuentes con
   wikilinks específicos. Los significados desconocidos siguen siendo una
   pregunta abierta. No inventes localizadores de evidencia.
4. Mantén una tabla con Término, Definición, Evidencia y Valoración. Un
   localizador de evidencia no es por sí solo una valoración aceptada. Aplica las
   reglas de afirmaciones y de fuentes al registrar definiciones factuales. Un
   glosario generado es una síntesis, no otra fuente independiente.
5. Para el material de origen aportado, usa un solo paquete de flujo de Ingesta.
   Para el contenido de la conversación seleccionado de forma explícita, usa
   Guardado y deja claro su origen sintético. Acopla páginas, catálogos,
   registros cuando cambien, bitácora y caché caliente acotada.

Una definición basada solo en un título, una etiqueta, el recuerdo del modelo o un
fragmento recuperado sin suficiente contexto de la fuente que lo rodea sigue sin
respaldo. Presenta la lista completa de términos, la cobertura de la evidencia y
las omisiones antes de aplicar. Informa el ID de operación y las rutas
modificadas, sin afirmar que se cubrió toda la bóveda a menos que se haya leído.

## Consolidar notas que se solapan

La consolidación cambia el conocimiento canónico y requiere consentimiento
explícito para la fusión identificada. Primero devuelve una propuesta de
solapamiento de solo lectura: rutas y hashes de origen, destino propuesto,
afirmaciones únicas que se conservarán, contradicciones, enlaces entrantes
existentes y los cambios exactos de catálogo y de registros. Una redacción
similar no prueba por sí sola que los significados sean equivalentes.

Tras la aprobación, vuelve a leer todos los destinos y reconstruye la propuesta si
algún hash cambió. Usa un solo paquete de flujo con `operation_type: ingest`.
Conserva la nota antigua como una nota de redirección breve con
`status: superseded`, con un wikilink y el motivo, y preserva la evidencia única y
las identidades estables de fuentes y afirmaciones. Deja sin cambios las cargas
útiles sin procesar originales. Incluye en ese único paquete la nota fusionada,
todas las notas de redirección aprobadas, el catálogo activo, la bitácora, la
caché caliente y las entradas modificadas de los registros.

El motor de transacciones admite `create` y `replace`, no la eliminación ni el
cambio de nombre. No elimines archivos, no reescribas enlaces entrantes no
relacionados ni implementes un movimiento con herramientas de archivos del host.
Si después se solicita una limpieza, planifícala por separado con una copia de
respaldo y aprobación explícita. Conserva byte a byte las regiones de Dataview,
Tasks, Templater, matemáticas y citas de fuentes, salvo que estén dentro del
alcance de edición aprobado.

Inspecciona con `workflow inspect`, aplica una sola vez el hash exacto revisado
con `workflow apply` y luego ejecuta el lint determinista. Un comprobante de
almacenamiento exitoso no establece la corrección editorial; revisa la cobertura
de la evidencia y cada enlace entrante que sobreviva. Ante un conflicto,
reconstruye. Tras una interrupción, usa `transaction recover`. No crees puntos de
control automáticos ni fusiones en silencio afirmaciones aceptadas que se
contradicen.
