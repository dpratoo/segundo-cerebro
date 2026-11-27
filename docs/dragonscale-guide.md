# Extensión de compatibilidad DragonScale

DragonScale es un conjunto opcional de experimentos de mantenimiento de la
memoria. La bóveda base no lo requiere. La extensión consta de cuatro ideas
independientes; su madurez y sus dependencias son distintas.

## Aprovisionamiento

Haz una vista previa de la transacción de configuración que solo crea:

```bash
bash scripts/setup-dragonscale.sh --vault <vault>
```

Aplica solo después de revisar las rutas faltantes:

```bash
bash scripts/setup-dragonscale.sh --vault <vault> \
  --generated-at <ISO-UTC> --approved-plan-sha256 <reviewed-sha256> --apply
```

La configuración crea solo los archivos que faltan del contador de direcciones,
de los umbrales de teselado, de las excepciones heredadas y del manifiesto
heredado. Nunca reemplaza valores existentes, descarga un modelo, cambia los
scripts del producto, sondea un servicio ni modifica notas.

## 1. Consolidaciones extractivas de la bitácora

`wiki-fold` crea un resumen consolidado acotado a partir de las entradas
recientes de `wiki/log.md`. Una consolidación debe ser:

- extractiva: cada afirmación apunta a una entrada hija;
- aditiva: las entradas hijas permanecen sin cambios;
- estructuralmente idempotente: el mismo conjunto de entrada produce la misma
  identidad de consolidación;
- previsualizada antes de que una transacción aplique la consolidación, el
  índice y la actualización de la bitácora.

Las consolidaciones son ayudas de navegación, no evidencia nueva. Si un resumen
consolidado no resulta útil, elimina o revierte solo la operación de
consolidación.

## 2. Direcciones estables

Las operaciones modernas solicitan direcciones mediante el paquete principal de
transacciones. El motor asigna el contador, inyecta el frontmatter de la página
y actualiza el mapa de direcciones heredado dentro del mismo diario. No llames
al asignador heredado en flujos de ingesta nuevos.

`scripts/allocate-address.sh` sigue siendo un diagnóstico de compatibilidad de
solo lectura para bóvedas antiguas. Acepta una bóveda explícita y nunca crea ni
adquiere un bloqueo. Su salida no reemplaza las garantías del motor de
transacciones en cuanto a hash esperado, asignación, concurrencia o reversión.

## 3. Diagnósticos de teselado semántico

`scripts/tiling-check.py` genera embeddings de las páginas elegibles mediante un
modelo de Ollama y compara cada par distinto de páginas en busca de posible
duplicación. Es opcional y sus umbrales semilla no están calibrados. Una
puntuación es una señal de revisión, no una prueba de que dos páginas deban
fusionarse.

Haz una vista previa sin escribir un informe:

```bash
python3 scripts/tiling-check.py --vault <vault> --peek
```

Los hosts remotos de Ollama se rechazan a menos que se indique
`--allow-remote-ollama`. Esa opción aprueba solo el endpoint. Aun así, cada
servidor debe demostrar que la nube está desactivada y que el modelo
seleccionado está instalado localmente con un digest válido y metadatos no
vacíos antes de leer cualquier dato de páginas o de la caché. Un modelo sin
etiqueta coincide solo con su nombre exacto o con `:latest`; las demás etiquetas
requieren una selección exacta. Calibra los umbrales con ejemplos etiquetados de
la bóveda seleccionada antes de usarlos como política. Si Ollama o el modelo no
están, informa ese estado de la capacidad; no des a entender que la revisión se
ejecutó.

La versión 2 del esquema de la caché del teselado vincula los embeddings con la
identidad y el digest resueltos del modelo. Una caché válida de la versión 1 es
un fallo de caché. Una caché mal formada sigue terminando con el código 3. Un
estado local sin demostrar, o cualquier ejecución de embeddings incompleta,
termina con el código 12. Las ejecuciones incompletas imprimen un informe
provisional y conservan los bytes de la caché anterior. Un escaneo completo sin
páginas elegibles informa `complete-empty` y termina con éxito.

## 4. Puntuación de frontera

`scripts/boundary-score.py` ordena las páginas que podrían merecer más
investigación según la estructura actual del grafo y su actualidad. Es
determinista y de solo lectura:

```bash
python3 scripts/boundary-score.py --vault <vault> --json --top 10
```

La puntuación propone dónde poner atención; no establece importancia ni verdad.
Usa un candidato como tema de autoresearch solo después de revisar sus enlaces
subyacentes y el presupuesto de investigación.

## Fallos y recuperación

- Un conflicto de configuración significa que cambió una ruta esperada; genera
  un plan nuevo.
- Una configuración interrumpida usa el comando normal de recuperación de
  transacciones.
- Un contador heredado dañado debería reconstruirse a partir de las direcciones
  observadas solo después de comprobar los duplicados y el mapa de direcciones.
- Una caché de teselado o un índice BM25 son derivados y pueden regenerarse. Las
  páginas de origen y los registros de procedencia no son cachés derivadas.
- Desactivar DragonScale no requiere una reescritura masiva. Deja de invocar los
  auxiliares opcionales; las páginas de consolidación y las direcciones
  existentes siguen siendo contenido normal de la bóveda.

## Verificación

Ejecuta las pruebas herméticas pertinentes o el conjunto completo de pruebas:

```bash
make test
```

La madurez de una capacidad se basa en comprobaciones ejecutadas, no en la
presencia de un archivo de configuración. Mantén cada mecanismo como opcional y
haz que falle de forma cerrada cuando sus requisitos previos no estén
disponibles.
