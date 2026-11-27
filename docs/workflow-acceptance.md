# Aceptación del flujo de trabajo de conocimiento

La validez del almacenamiento y la completitud del conocimiento son
comprobaciones separadas. Una transacción recuperable puede omitir la entrada de
catálogo de la nota o el historial de la operación. El guardado y la ingesta
usan el control específico del flujo de trabajo:

```bash
python3 "$CORE" workflow inspect "$BUNDLE" --vault "$VAULT"
# Lee storage_valid, workflow_complete, findings y approval_sha256.
python3 "$CORE" workflow apply "$BUNDLE" --vault "$VAULT" \
  --approved-plan-sha256 "$APPROVAL_SHA256"
```

Define `APPROVAL_SHA256` solo a partir del resultado de la inspección ya
revisado. `transaction inspect/apply` genérico sigue siendo la interfaz de
almacenamiento para otras operaciones autorizadas; no sustituye esta
comprobación de aceptación del flujo de trabajo.

Las operaciones de contenido de guardado y de ingesta acoplan las escrituras de
la nota o página, una escritura vinculada a un hash del catálogo activo, una
entrada de la bitácora y un contexto de caché caliente de como máximo 500
palabras y 32 KiB (el límite de contexto de SessionStart). El catálogo
predeterminado es `wiki/index.md`. Para declarar otro MOC de metodología activo,
coloca su ruta exacta relativa a la bóveda en el paquete:

```json
{
  "workflow": {
    "catalogs": ["wiki/maps/Research.md"]
  }
}
```

Este es un campo dentro de un paquete `claude-obsidian.transaction.v1` completo,
no un documento independiente que se pueda aplicar. Incluye los hashes esperados
y las escrituras de los catálogos declarados. Toda página de contenido canónica
seleccionada, ya sea creada o reemplazada, requiere una referencia visible en el
contenido previsto de una escritura de catálogo declarada. Usa un wikilink con
ruta completa o un enlace Markdown relativo desde ese catálogo a cada página
canónica seleccionada. Una nota que ya está indexada puede dejar sin cambios los
bytes del catálogo: aporta su contenido existente como una escritura `replace` y
vincula su SHA-256 actual en `expected_hashes`. No hace falta ninguna edición de
texto sin sentido en el catálogo. Un catálogo sin cambios que omite una página
seleccionada no pasa el control. `changed_paths` enumera los destinos de la
transacción; su sola presencia no demuestra que los bytes hayan cambiado. La
escritura del catálogo y el hash siguen siendo obligatorios para las páginas
existentes, de modo que la navegación y la actualización de la nota queden en la
misma operación aprobada y recuperable, y en su reejecución. Los catálogos y las
páginas de contenido seleccionadas deben usar rutas canónicas visibles: un
directorio o nombre de archivo con prefijo de punto no puede cumplir esta
obligación de navegación.
Un catálogo activo es un catálogo declarado en `workflow.catalogs` que es
`wiki/index.md` o que ya existe (una escritura `replace` vinculada a un hash).
Un catálogo que crea el mismo paquete debe estar enlazado desde una de esas
escrituras de catálogo activo; de lo contrario, la inspección informa
`INACTIVE_CATALOG`, de modo que una página nueva y desechable no pueda sustituir
la navegación. Para enlazar un MOC nuevo desde
el índice raíz, incluye `wiki/index.md` en la lista junto al MOC para que
también quede declarado en `workflow.catalogs`; una escritura del índice no
declarada no cuenta. El control no puede juzgar si una página declarada ya
existente es un MOC útil.

La ingesta incluye escrituras tanto del registro de fuentes como del registro de
afirmaciones; el guardado incluye los registros cuando cambiaron las entradas
de evidencia. La ingesta también necesita una fuente: contenido `.raw/` de solo
creación en el paquete, o una fuente registrada en el registro de fuentes
previsto (`MISSING_INGEST_SOURCE`). Al menos un registro debe cambiar; las
reescrituras idénticas byte a byte de ambos informan `UNCHANGED_PROVENANCE`. La
nueva primera entrada de la bitácora, el primer encabezado `## ` del cuerpo de
la bitácora, usa `## [YYYY-MM-DD] save|...` o `## [YYYY-MM-DD] ingest|...`.
Puede ir directamente debajo del título y la introducción de la bitácora, como
en la bitácora que siembra `init`. Toda entrada existente permanece sin cambios
después de la nueva, y toda otra línea existente conserva su orden; de lo
contrario, la inspección informa `LOG_HISTORY_NOT_PRESERVED`. La fecha debe ser
una fecha real del calendario, no solo un patrón de dígitos que coincida. No
fabriques afirmaciones ni fuentes registradas para satisfacer un validador.

La inspección del flujo de trabajo materializa borradores `content_file` UTF-8
vinculados a un hash. Tras una aplicación exitosa, la reejecución puede usar los
bytes de destino confirmados cuando un borrador desechable ya no existe. Para la
asignación administrada de direcciones, solo puede revertir la inserción exacta
generada en la segunda línea, y solo cuando esos bytes recuperados coinciden con
el hash original declarado. El hash de contenido declarado, el paquete
materializado original, la aprobación y el resultado completado siguen teniendo
que coincidir. Se rechaza un borrador disponible cuyos bytes cambiaron, y
también los destinos, modos o hashes esperados que cambiaron. Mover un borrador
con bytes declarados idénticos no cambia la operación materializada. La
reejecución de una operación completada exige además el diario conservado y el
paquete expandido: sus identidades, la cobertura de escrituras y los hashes de
contenido deben correlacionarse con el resultado bajo el bloqueo de la
transacción. Un comprobante por sí solo no puede certificar una operación
completada. Las entradas históricas que solo tienen comprobante permanecen
intactas durante operaciones no relacionadas, pero no pueden autorizar una
reejecución. Esta equivalencia no relaja las comprobaciones de reejecución ni de
deriva del resultado del motor de transacciones.

Un JSON de resultado retenido mal formado, el UTF-8 no válido, el anidamiento
excesivo de JSON, los metadatos de resultado nulos o incompletos, los modos o
tipos de operación que no son texto y las escrituras de reejecución mal formadas
devuelven errores de transacción controlados. Un diario retenido que sigue en
estado `prepared` no puede certificar la finalización. Un FIFO u otro archivo no
regular en la ruta de un comprobante, de la bitácora o de un destino se rechaza
sin bloquear. La reejecución de una operación completada no lee la
`wiki/log.md` actual; el resultado retenido la vincula. Reutilizar el ID de una operación completada con
otro tipo de operación informa `OPERATION_ID_REUSED`, igual que lo hace
`transaction apply` con otro paquete. Una reejecución rechazada no autoriza una
operación nueva ni modifica la bóveda. Una bitácora existente con UTF-8 no
válido devuelve `WORKFLOW_LOG_NOT_TEXT` antes de que la inspección pueda aprobar
su reemplazo. Conserva sus bytes originales y revisa una reparación aparte, en
lugar de descartar en silencio un historial que no se puede analizar.

El lint y la navegación del flujo de trabajo comparten la protección de los
comentarios HTML y `%%` de Obsidian, el código en línea de igual longitud, las
cercas de acentos graves o de tildes (cerradas por una secuencia igual o más
larga), el código con sangría, los corchetes de apertura escapados y las
fórmulas matemáticas con `$` o `$$`. El enmascarado conserva los desplazamientos
del origen y los números de línea. Los enlaces de continuación de una lista
siguen siendo visibles cuando su sangría es relativa a un elemento de la lista y
no a un bloque de código. Una cerca contenida en una lista termina cuando
termina su contenedor de lista, incluida una cerca sin cerrar seguida de un
párrafo exterior o de un elemento hermano. El texto literal de un destino no se
analiza como fórmula matemática ni como comentario de la prosa; el código o los
comentarios que lo envuelven siguen ocultando el enlace completo. Los enlaces
Markdown en línea admiten etiquetas de una sola línea con corchetes balanceados,
destinos entre ángulos, paréntesis balanceados y títulos opcionales entre
comillas o entre paréntesis. Los escapes y el código en línea dentro de una
etiqueta no crean corchetes de etiqueta adicionales. Los destinos decodificados
siguen pasando las comprobaciones de confinamiento en la bóveda. Las etiquetas
de los encabezados renderizan los enlaces en línea admitidos fuera del código;
los fragmentos solicitados nombran el texto resultante y no se reinterpretan
como enlaces nuevos. Por lo tanto, un wikilink literal dentro de código en línea
sigue siendo una etiqueta de encabezado distinta. Este es un subconjunto estático
de navegación, no un renderizador completo de CommonMark ni de Obsidian: los
enlaces de estilo referencia, las anclas HTML, el análisis de contenedores de
citas, la sintaxis de complementos y el renderizado nativo quedan fuera de su
cobertura.

El control determinista comprueba la estructura y el acoplamiento declarados. No
puede decidir si la prosa es útil, si una cita respalda una afirmación o si una
respuesta está completa. Usa los escenarios congelados de guardado, ingesta y
consulta que están en `tests/fixtures/forward/` para la aceptación del host con
contexto nuevo. Conserva las versiones del host y del modelo, los prompts y las
salidas, los hashes de antes y después, los comprobantes de operación, los
hallazgos del revisor y las comprobaciones exactas que faltan. La consulta debe
dejar sin cambios cada byte de la bóveda y abstenerse cuando falte respaldo.
Prueba tanto una bóveda limpia como una copia heredada representativa.

Los fixtures simulados o sin conexión, las ejecuciones reales de modelos, el
renderizado nativo de Obsidian y la aceptación humana son clases de evidencia
distintas. No promuevas una clase a otra. El [evaluador de prompts sin
conexión](prompt-evaluation.md) comprueba contratos de respuesta explícitos y
controles negativos antes de cualquier prueba de modelo aprobada por separado;
no reemplaza la aceptación del flujo de trabajo con bóveda desechable descrita
arriba.
