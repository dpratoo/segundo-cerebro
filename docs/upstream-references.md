# Conciliación de las referencias de upstream

`config/upstream-references.json` registra las revisiones de los repositorios
primarios revisadas el 2026-10-17, las rutas inspeccionadas, los límites de
licencia, las referencias locales y las divergencias intencionales. Son
observaciones de fuente con fecha, no versiones de entorno de ejecución
instaladas ni afirmaciones sobre la punta actual de la rama. Esta actualización
no importa código de upstream, corpus de fixtures, marca ni prosa sustancial.

Comprueba los hashes de las alternativas locales antes de revisar un cambio. Una
discrepancia de hash significa que el texto local necesita conciliación; no es
permiso para restaurar el texto antiguo. Compara una revisión de upstream
propuesta con la revisión fijada mediante una lectura de red solicitada
explícitamente. Revisa el comportamiento, la autoridad de la fuente, los cambios
de licencia y la compatibilidad con la aplicación antes de mover una fijación.
Nunca descargues y reemplaces skills automáticamente. Conserva la interfaz de
15 skills y el límite transaccional de la bóveda, salvo que un diseño revisado
por separado los cambie.

Al actualizar una referencia, registra el SHA candidato, las rutas exactas
inspeccionadas, la fecha de obtención, la evidencia nativa cuando esté
disponible y las nuevas divergencias intencionales. Después actualiza los hashes
locales afectados y ejecuta las pruebas de ejemplos de referencia y las
comprobaciones de paquete y de contratos. Mover una fijación sin revisar el
contenido no es una actualización de upstream. Este manifiesto no implica ningún
planificador ni instalación.

Las referencias MIT siguen requiriendo sus avisos cuando se copian porciones
sustanciales. Templater es un objetivo de interoperabilidad bajo AGPLv3; no
copies su código en este producto MIT sin una decisión de licencia aparte. Smart
Connections usa una licencia personalizada restringida, así que su implementación
queda excluida de la copia. Los recursos de marketing de Web Clipper quedan fuera
de su concesión MIT del código fuente. Una skill que menciona a Knap no otorga
ninguna licencia sobre el propio Knap, que no se inspeccionó.

Desacuerdo conocido: la Ayuda oficial de Bases describe las diferencias de fechas
en milisegundos, mientras que el registro de cambios de la 1.9.3 y la skill de
upstream describen una Duration. Los extractos registrados de `obsidian.d.ts` no
incluyen una definición de Duration y no se citan para ninguno de los dos lados.
Conserva esto como no resuelto hasta que existan pruebas nativas de la aplicación
compatibles.
La skill local de Defuddle se detiene intencionalmente en los planes inertes y en
la captura del sistema de archivos, incluso cuando una receta de upstream
ejecutaría la CLI. Las reglas locales de transacciones, de no instalación
automática, de bóveda seleccionada y de consentimiento de red siguen siendo las
que prevalecen.
