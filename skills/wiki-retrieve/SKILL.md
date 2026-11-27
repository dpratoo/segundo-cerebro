---
name: wiki-retrieve
description: "Crea y consulta un índice de recuperación BM25 contextual y local a la bóveda, con reordenamiento opcional por coseno multilingüe de Nomic. Las cachés derivadas quedan en .vault-meta, la salida de red requiere consentimiento explícito y, sin reordenamiento disponible, se usa una alternativa determinista. Se activa con: retrieve, recuperación híbrida, BM25, rerank, recuperación contextual, búsqueda por fragmentos, búsqueda en la bóveda, búsqueda semántica, encuentra pasajes relevantes, diagnóstico de recuperación."
---

# Buscar pasajes relevantes

Esta extensión deriva datos de búsqueda de `wiki/` hacia `.vault-meta/`. Nunca
cambia las notas canónicas. Pasa siempre la bóveda seleccionada de forma
explícita.

Resuelve la raíz del producto instalado a partir de la ubicación de esta skill,
no de la bóveda ni del directorio de trabajo actual:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
PREFIX="$PRODUCT_ROOT/scripts/contextual-prefix.py"
BM25="$PRODUCT_ROOT/scripts/bm25-index.py"
RETRIEVE="$PRODUCT_ROOT/scripts/retrieve.py"
RERANK="$PRODUCT_ROOT/scripts/rerank.py"
test -f "$PREFIX" && test -f "$BM25" && test -f "$RETRIEVE" && test -f "$RERANK"
```

## Flujo

1. `contextual-prefix.py` divide las páginas en los límites de párrafo y guarda
   el fragmento sin procesar junto con un prefijo breve a nivel de página.
2. `bm25-index.py` construye un índice BM25 local, solo con la biblioteca
   estándar, sobre el texto contextualizado.
3. `retrieve.py` selecciona candidatos BM25, los reordena de forma opcional,
   rechaza los registros no válidos, elimina duplicados por página y devuelve
   rutas y extractos.
4. Quien invoca lee las páginas devueltas y hace la síntesis; la salida de la
   búsqueda no es por sí misma evidencia.

## Aprovisionar en local

Primero haz una vista previa y luego construye prefijos sintéticos sin salida de
red:

```bash
python3 "$PREFIX" --vault "$VAULT" --all --no-llm --peek
python3 "$PREFIX" --vault "$VAULT" --all --no-llm
python3 "$BM25" --vault "$VAULT" build
python3 "$RETRIEVE" --vault "$VAULT" "wiki" --top 1 --no-rerank --explain
```

Los archivos de fragmentos y de índice son estado de ejecución desechable. El
prefijado incremental omite los registros cuyos hashes de fragmento, hashes de
página y perfil de proveedor y modelo siguen coincidiendo. Los registros
heredados sin ese perfil se regeneran en una construcción explícita. Un escaneo
completo elimina los registros sobrantes de páginas eliminadas, y el proceso de
prefijado invalida el índice BM25 antes de cambiar su conjunto de fragmentos,
para que no se sirva un índice obsoleto mezclado. Las operaciones de
construcción de prefijos y de BM25 comparten el bloqueo de modificación de toda
la bóveda con cualquier otro proceso que escriba; una bóveda ocupada falla de
forma cerrada en lugar de publicar un índice parcial.

## Privacidad de los prefijos contextuales

Los prefijos sintéticos usan solo el frontmatter local y el texto de la página.
El perfil explícito de la API de Anthropic puede enviar el cuerpo de las páginas
fuera del equipo y requiere el consentimiento del usuario, además de
`--allow-egress` y una clave de API configurada. No existe un nivel de
generación con la CLI de Claude ni una alternativa mediante subprocesos del
entorno. Nunca infieras el consentimiento a partir de una clave de API ni de un
binario instalado. Haz primero una vista previa del alcance e indica qué
proveedor recibirá qué datos.

Los endpoints remotos de Ollama también requieren aprobación explícita y
`--allow-remote-ollama`; el reordenador por defecto acepta solo localhost.

Los prefijos con un modelo local son una opción explícita aparte. Usa un
`name:tag` exacto ya instalado; no se inicia ningún servidor ni se instala o
descarga ningún modelo:

```bash
python3 "$PREFIX" --vault "$VAULT" --all --local-ollama --ollama-model installed:tag --peek
python3 "$PREFIX" --vault "$VAULT" --all --local-ollama --ollama-model installed:tag
```

El adaptador de prefijos verifica que el estado del servidor indique la nube
desactivada y la identidad del modelo local antes de enviar texto de páginas. Si
la verificación previa no es compatible o no está disponible, se recurre a
prefijos sintéticos solo para los fragmentos nuevos o modificados; los prefijos
del mismo endpoint y modelo se conservan, de modo que una interrupción
transitoria deja intactos los fragmentos y el índice BM25 de una bóveda sin
cambios. Este requisito puede excluir servidores de Ollama más antiguos.
El reordenamiento y el teselado usan la misma prueba de ejecución solo local
antes de trabajar con consultas, páginas, fragmentos o la caché de embeddings.
`--allow-remote-ollama` aprueba el endpoint, no la delegación a la nube por
parte del servidor.
Consulta los [proveedores de prefijos](../../docs/prefix-providers.md) para la
política exacta, la selección de modelos en la nube y los límites de
verificación. El reordenador tiene su propia política de modelo y de endpoint;
elegir prefijos locales no habilita el reordenamiento.

## Consultar

Para una consulta estrictamente de solo lectura, usa el índice BM25 ya
construido:

```bash
python3 "$RETRIEVE" --vault "$VAULT" "$QUERY" --top 5 --no-rerank --explain
```

Para un reordenamiento solicitado de forma explícita, omite `--no-rerank`. El
valor por defecto es el modelo multilingüe `nomic-embed-text-v2-moe` de Ollama
(aproximadamente 958 MB); el producto nunca lo descarga de forma automática.
Para usar un modelo v1.5 ya instalado, más pequeño y orientado al inglés, indica
`--model nomic-embed-text` de forma explícita. Los modelos de Nomic usan
`search_query:` para la consulta y `search_document:` para el texto de los
candidatos. Nomic v2 tiene un contexto de entrada de 512 tokens y Ollama trunca
por defecto las entradas de embeddings más largas; BM25 sigue puntuando el
fragmento completo. Los embeddings se guardan en caché según el modelo exacto,
el digest verificado, el esquema de entrada y el hash de la entrada exacta con
prefijo. Si falta el servicio local de Ollama, si la respuesta HTTP está mal
formada, si falta el modelo seleccionado, si un vector no se puede usar o si
falla el embedding de cualquier candidato, todo el conjunto de resultados
recurre al orden original de BM25; nunca se mezclan las escalas de puntuación
del coseno y de BM25.

La entrada de la consulta está acotada a 8,000 caracteres normalizados y la
cantidad de resultados debe estar entre 1 y 1,000. Las consultas demasiado
largas y los límites no válidos fallan con un error de uso accionable, en lugar
de parecer una búsqueda vacía y exitosa. Una solicitud de modelo sin etiqueta
coincide solo con el nombre instalado sin etiqueta o con su alias `:latest`;
selecciona explícitamente cualquier otra etiqueta.

Usa diagnósticos directos cuando haga falta:

```bash
python3 "$BM25" --vault "$VAULT" stats
python3 "$BM25" --vault "$VAULT" query "$QUERY" --top 10
python3 "$RERANK" --vault "$VAULT" "$QUERY" --peek
python3 "$RERANK" --vault "$VAULT" "$QUERY" --model nomic-embed-text --peek
```

## Reglas de integridad

- Acepta solo rutas relativas de fragmentos y de páginas cuyos destinos
  resueltos permanezcan bajo `$VAULT/.vault-meta/chunks/` y `$VAULT/wiki/`,
  respectivamente.
- Rechaza los registros de fragmentos heredados sin hash y exige que coincidan
  los hashes del cuerpo del fragmento, de la página y del índice antes de
  construir o servir un registro en caché.
- Rechaza las rutas absolutas, las salidas mediante enlaces simbólicos, las
  páginas inexistentes, los ID de fragmento que no coinciden, los hashes de
  página modificados y los pares de hashes de índice y fragmento obsoletos.
- Reordena el conjunto completo de candidatos, luego elimina duplicados por
  página y después aplica `--top`.
- Un índice vacío es un estado honesto de ausencia de resultados. Un índice
  faltante o dañado hace que `retrieve.py` termine con el código 10 y un comando
  de reconstrucción estable; quienes lo invocan recurren a la ruta estándar de
  consulta de la bóveda o de búsqueda de texto y no inventan coincidencias.
- No cites porcentajes de pruebas comparativas a menos que los haya producido
  una prueba comparativa reproducible específica de la bóveda.

Mide un índice ya construido con etiquetas explícitas mediante
`bench --queries FILE
--vault VAULT`. Consulta la
[evaluación de búsqueda sin conexión](../../docs/retrieval-evaluation.md) para
conocer el recall, el MRR, las etiquetas faltantes y los casos negativos. Es una
medición de solo lectura y nunca reconstruye un índice en silencio ni llama a un
modelo.

## Punto de control

Observa si las cachés están listas y cuáles son los límites de privacidad,
piensa si hace falta un ordenamiento léxico o semántico, verifica las rutas
devueltas y la vigencia de las fuentes, y crece midiendo los fallos de la
búsqueda con un conjunto de consultas local y mantenido.
