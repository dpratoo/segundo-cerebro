# Evaluación de búsqueda sin conexión

Usa etiquetas de relevancia explícitas para medir un índice BM25 local ya
construido. La evaluación lee las páginas y las cachés seleccionadas sin
reconstruirlas. Siempre pasa `--no-rerank`, no hace llamadas a modelos ni a
proveedores y nunca aprovisiona una bóveda de usuario. Los resultados
informados describen la instantánea y el conjunto de consultas seleccionados.

Usa rutas físicas para los archivos de etiquetas de consultas. El lector rechaza
los enlaces simbólicos en cada componente de la ruta, incluidos alias de macOS
como `/tmp` y `/var`. Resuelve el directorio contenedor de confianza antes de
crear allí archivos de etiquetas normales; las entradas que sean enlaces
simbólicos explícitos siguen siendo no válidas.

```bash
python3 scripts/evaluate-retrieval.py --vault /absolute/vault \
  --queries /absolute/queries.json
```

La API del núcleo es `run_quality(vault, query_file, product_root, top_k=10)`.
La CLI portátil también expone la misma evaluación a través de `bench --queries FILE
--vault VAULT`. Ambas requieren un índice existente. Un estado derivado faltante
o dañado termina con el código 10 y un diagnóstico de reconstrucción. Las
etiquetas no válidas, las rutas no seguras o una instantánea que cambia terminan
con el código 2. Reconstruir un índice es una operación explícita aparte.

## Escribir etiquetas útiles

Cada consulta necesita un ID, el texto exacto de la consulta y una lista
explícita de las rutas de páginas Markdown relevantes, relativas a la bóveda.
Las listas vacías significan que no se espera ninguna respuesta de este corpus.
Se evalúan como casos negativos; nunca inflan el recall ni el MRR dividiendo
entre cero ni contando un acierto gratuito.

```json
{
  "schema": "claude-obsidian.retrieval-queries.v1",
  "queries": [
    {
      "id": "journal-recovery",
      "query": "recover interrupted writes",
      "expected_pages": ["wiki/concepts/Recovery.md"],
      "category": "recovery"
    },
    {
      "id": "unanswerable",
      "query": "a topic absent from the vault",
      "expected_pages": [],
      "category": "negative"
    }
  ]
}
```

Escribe las etiquetas a partir de la necesidad de información antes de ajustar
la búsqueda. Incluye identificadores exactos, formulaciones en lenguaje natural,
sinónimos, nombres con Unicode, varias páginas relevantes, material obsoleto,
registros en conflicto y temas realmente ausentes. Mantén un conjunto de reserva
aparte para cambios futuros. No reescribas las etiquetas para que se ajusten al
ordenamiento de candidatos.

Un `skip_reason` opcional marca una exclusión explícita. El informe la registra.
Una consulta con una página de referencia faltante también se excluye de las
métricas agregadas y se lista con sus rutas faltantes. Los enlaces simbólicos no
seguros, las junctions, el recorrido de directorios, las rutas absolutas, las
etiquetas duplicadas y los archivos no regulares fallan de forma cerrada. Los
archivos de etiquetas están acotados a 1 MiB, los conjuntos de consultas a 1,000
entradas, cada consulta a 8,000 caracteres normalizados y cada conjunto de
referencia a 64 páginas. Las lecturas usan descriptores sin seguimiento de
enlaces en las plataformas que los admiten y rechazan los componentes que sean
enlaces en las demás.

## Interpretar el informe

El recall en 1, 5 y 10 es la fracción de las páginas de referencia de una
consulta presentes entre las primeras 1, 5 o 10 páginas distintas devueltas. El
agregado es la media de las consultas puntuadas que tienen listas de referencia
no vacías. Por lo tanto, una consulta con dos páginas relevantes y un primer
resultado correcto tiene un recall en 1 de 0.5.

El MRR es la media del rango recíproco de la primera página relevante. Una
primera página relevante en la posición 2 aporta 0.5; una página relevante
ausente aporta 0. El corte por defecto es 10. `--top` puede aumentar la
profundidad medida; la profundidad mínima sigue siendo 10 para que los tres
cortes de recall tengan observaciones comparables.

Cada métrica incluye su propio `n` y su estado. `n = 0` se muestra como
`no data` con un valor nulo. Las consultas con referencia vacía tienen una
exactitud de ausencia de resultados aparte, con su propio denominador. Las
consultas con referencia faltante y las omitidas de forma explícita tienen
conteos aparte. Las filas por consulta exponen los ordenamientos, los fallos en
cada corte, el rango recíproco, la latencia del proceso y los diagnósticos de la
búsqueda.

El conjunto de candidatos es de al menos 20 fragmentos BM25 y crece con la
profundidad solicitada. El recall de candidatos utilizables se informa por
separado, después del filtrado de obsoletos y de la eliminación de páginas
duplicadas. El recall de candidatos BM25 sin procesar no está disponible porque
`retrieve.py
--explain` expone los conteos de candidatos sin procesar sin las identidades de
sus páginas. Este alcance queda registrado directamente en el informe. La
latencia incluye el arranque del proceso, la carga del índice y el trabajo de la
consulta. P50 y P95 usan percentiles por rango más cercano.

Los hashes exactos de bytes de las etiquetas y del índice vinculan una ejecución
con sus entradas. Un cambio en cualquiera de los dos durante la evaluación
invalida la ejecución. La comprobación del hash de página en la búsqueda rechaza
los fragmentos obsoletos. Una prueba comparativa no toma el bloqueo de
modificación de toda la bóveda; ejecútala mientras los demás procesos de
escritura estén inactivos. El informe se devuelve por stdout y puede guardarse
fuera de la bóveda del usuario cuando se necesite una comparación duradera.

Los registros de fragmentos mal formados o que no se pueden decodificar se
cuentan como candidatos obsoletos omitidos; los candidatos sanos siguen
disponibles. La vigencia de la página exige UTF-8 estricto, de modo que unos
bytes de página dañados no pueden coincidir con un carácter de reemplazo
literal en caché mediante una decodificación con pérdida. Los fragmentos y las
páginas rechazados no se reparan durante una consulta.

## Ejecutar el fixture original

La copia del código fuente incluye 14 consultas originales etiquetadas sobre 10
páginas inventadas. Contiene francés, japonés, rumano, búsqueda por dirección
exacta, búsqueda con varias páginas de referencia, un fallo léxico intencional
de sinónimos, historial obsoleto en conflicto y casos explícitos sin respuesta.

```bash
python3 scripts/evaluate-retrieval.py --fixture
python3 tests/test_retrieval_eval.py
```

El modo fixture crea solo un directorio temporal, copia las páginas inventadas,
ejecuta `contextual-prefix.py --all --no-llm`, construye BM25 y modifica una
página del fixture después de indexar para probar el rechazo de cachés
obsoletas. Luego ejecuta el mismo evaluador de solo lectura y elimina el
directorio temporal. Rechaza un destino existente a través de su API de
aprovisionamiento. El informe incluye los hashes de todos los archivos
originales del fixture. Los hashes del índice pueden variar entre construcciones
porque los registros derivados incluyen metadatos de la construcción; los
hashes del contenido del fixture son estables.

Las distribuciones que excluyen los fixtures de prueba del código fuente siguen
admitiendo la evaluación con etiquetas proporcionadas por el usuario. En ese
caso, `--fixture` informa que su fixture de origen no está disponible. Nunca
cambia en silencio a un corpus distinto.

Este fixture establece un comportamiento ejecutable y una línea base local
repetible. No establece la calidad en una bóveda real, el comportamiento nativo
de Obsidian, la calidad semántica de un modelo ni una mejora de calidad respecto
de una versión publicada anterior. Compara los candidatos con las mismas
etiquetas y el mismo corpus sin cambios, y conserva el resultado de cada
consulta, incluidos los fallos y las exclusiones.
