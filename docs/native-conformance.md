# Procedimiento de conformidad nativa de Obsidian

Las comprobaciones del analizador sin conexión no establecen el comportamiento de
la aplicación. Usa una bóveda fixture desechable y una versión de Obsidian
compatible declarada para la aceptación nativa. No se necesita ninguna bóveda
real, instalación de complementos ni cambio de cuenta para el trabajo estático.
No instales un entorno de ejecución ni un complemento solo para que una
comprobación no verificada parezca aprobada.

Registra la versión de la aplicación, la plataforma (escritorio o dispositivo móvil),
la zona horaria, los complementos principales y comunitarios habilitados con sus
versiones, los hashes de los fixtures, la fecha y la clase de evidencia.
Clasifica cada observación como fuente o estática, CLI oficial o aplicación real.
Marca como no verificado todo lo que no se haya ejercitado. Conserva las capturas
de pantalla o la salida exacta de la CLI y un pequeño resultado legible por
máquina por caso; no infieras que un renderizado pasó a partir de un YAML válido.

## Casos fixture originales

| Caso | Fixture y observación esperada que se debe registrar |
|---|---|
| Rutas de Markdown | Nombres de archivo con espacios y con codificación porcentual, etiquetas de alias, nombres base duplicados en carpetas distintas, enlaces dentro de la misma nota, encabezados anidados e ID de bloque. Registra el destino resuelto o el estado nativo de no resuelto. |
| Regiones protegidas | Código con sangría, bloques de código anidados, comentarios, sintaxis escapada, matemáticas, destacados y notas al pie. Registra cuáles de los supuestos enlaces son enlaces reales y conserva los bytes durante las ediciones no relacionadas. |
| Propiedades | Propiedades planas con tipo, wikilinks entre comillas y listas de enlaces, etiquetas semánticas de año y etiquetas Unicode. Los valores solo numéricos van en una propiedad numérica, no en etiquetas. |
| Incrustaciones | Vista `.base` con nombre, página y opciones de PDF, tamaño de imagen y nodos de archivo de Canvas. Registra por separado la selección de la vista con nombre y el comportamiento de red al renderizar. |
| Bases | Tabla y tarjetas en 1.9+, lista en 1.10+, kanban en 1.14+, groupOrder ausente, vacío, explícito o null, y agrupación por una fórmula de solo lectura. Registra las filas del resultado y la visibilidad de los grupos. |
| Fórmulas de fechas | Casos fijos de un día, de varios meses, negativos, con fecha ausente y de zona horaria. Compara la resta y la división, el campo de días de Duration y la conversión explícita a número. Registra el tipo y el valor reales del resultado y los errores sin elegir un ganador de antemano. |
| Sintaxis opcional | DQL, DataviewJS, Templater, recurrencia y sangría de Tasks y espacios finales existentes. La lectura, la ingesta y el lint normales no deben ejecutar código; las ediciones de prosa no relacionadas conservan esos bytes. |
| Selección de la CLI | Dos bóvedas fixture abiertas. Ejecuta la lista de permitidos de solo lectura mediante la identidad explícita de la bóveda seleccionada; demuestra que la otra bóveda no cambió. |

Usa texto fixture original y registros sintéticos. No copies el corpus de pruebas
de un tercero sin su licencia y su atribución. Un resultado de lint portátil se
compara con el grafo de destinos nativo registrado solo para el subconjunto
admitido. Mantén visibles los casos ambiguos o no admitidos. Las observaciones
nativas de la aplicación no establecen la compatibilidad de escritura en
Windows, la convergencia de la sincronización en la nube, la calidad de los
proveedores ni todas las versiones de los complementos.

Cuando aparezca una discrepancia, conserva el caso que falla, la evidencia de la
aplicación, el resultado exacto del analizador y la divergencia intencional antes
de cambiar una implementación o una fijación de fuente. Nunca actualices
automáticamente los fixtures esperados en una ejecución de pruebas normal.
