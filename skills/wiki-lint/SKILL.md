---
name: wiki-lint
description: "Hace una revisión de salud determinista y de solo lectura de una wiki de Obsidian. Informa sobre grafo, enlaces, frontmatter, registro de procedencia, secciones vacías e índice obsoleto; no razona en sentido amplio ni repara archivos. Se activa con: lint, revisa la salud de la bóveda, audita la salud de la wiki, busca páginas huérfanas, busca enlaces rotos, audita el frontmatter, audita la procedencia, audita la wiki."
---

# Ejecutar el lint de la wiki

Usa el motor de lint portátil como fuente de verdad. El lint observa el estado
de la bóveda; no crea informes, paneles, canvases, esbozos ni correcciones.

Resuelve la raíz del producto instalado a partir de la ubicación de esta skill,
no de la bóveda ni del directorio de trabajo actual:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.

## Ejecución

Resuelve la bóveda del usuario y luego ejecuta uno de estos comandos:

```bash
python3 "$CORE" lint --vault "$VAULT"
python3 "$CORE" lint --vault "$VAULT" --format markdown
python3 "$CORE" lint --vault "$VAULT" --exclude "wiki/scratchpad/*"
```

El flag repetible `--exclude GLOB` deja una ruta (por ejemplo, una carpeta de
borradores) fuera del análisis de páginas, de la resolución de enlaces, de
páginas huérfanas, de frontmatter, de secciones vacías y de entradas de índice
obsoletas.

Usa `--strict` solo cuando un código de salida distinto de cero ante hallazgos
sea útil en automatización. El comando sigue siendo de solo lectura en ambos
casos.

El analizador determinista entiende los wikilinks y las incrustaciones de
Obsidian, los enlaces de Markdown, los alias, los fragmentos de encabezado y de
bloque, los alias con escape y los bloques de código cercados. Omite por defecto
los directorios que empiezan por punto, igual que el indexador propio de
Obsidian. La resolución de enlaces respeta los archivos `.gitignore` dentro de
la bóveda (sin subproceso de `git`): cuando un enlace es ambiguo entre una
página y un archivo ignorado por git, como un artefacto de compilación, se
descarta el candidato ignorado.
Informa categorías como enlaces rotos o ambiguos, páginas huérfanas, campos
de frontmatter obligatorios que faltan (incluido `title`), secciones vacías,
entradas de índice obsoletas y violaciones del contrato de los registros de
fuentes y de afirmaciones. Informa solo las comprobaciones y los conteos presentes
en su salida; no afirmes que realizó un análisis semántico, estilístico o de
contradicciones a nivel de prosa cuando no lo hizo.

## Explicar los hallazgos

1. Conserva las rutas, los números de línea, los destinos, las categorías y los
   conteos del motor.
2. Agrupa los hallazgos por probable impacto: navegación rota, resolución
   ambigua, calidad de los metadatos y, por último, mantenibilidad.
3. Explica que una página huérfana puede ser intencional y que un nombre base
   ambiguo requiere un enlace con la ruta completa; no deduzcas la intención a
   partir del hallazgo solo.
4. Trata los hallazgos de la lista de permitidos como política, no como prueba
   de que el destino exista.
5. Separa los hechos deterministas de la corrección sugerida.

No escribas la versión en Markdown del informe dentro de la bóveda. Devuélvela
en el chat o por la salida estándar.

## La reparación es una operación aparte

Nunca corrijas automáticamente un resultado del lint. Después de que el usuario
elija los hallazgos concretos que quiere reparar:

1. Vuelve a leer cada destino y registra su SHA-256 esperado.
2. Redacta solo los cambios seleccionados; no elimines ni fusiones páginas sin
   consentimiento explícito.
3. Construye un único paquete de reparación con un ID de operación nuevo.
4. Inspecciona el paquete y muestra las rutas exactas que cambian.
5. Aplica solo después de esa revisión aparte.
6. Vuelve a ejecutar el lint en modo de solo lectura y compara los hallazgos
   relevantes.

Sigue el [contrato de transacciones de operaciones](../wiki/references/operation-transactions.md).
El lint nunca aplica esa transacción ni hace commit en Git.

## Punto de control

Observa el informe determinista, piensa en las causas de fondo y no en la
cantidad de hallazgos, verifica las reparaciones propuestas contra los hashes
actuales y crece mejorando el flujo de trabajo que produjo los hallazgos
repetidos.
