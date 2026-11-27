---
name: canvas
description: "Crea, inspecciona y actualiza tableros JSON Canvas de Obsidian con nodos de texto, archivo, enlace y grupo, y con conexiones. Úsala para el estado o la lista de los canvas, mapas visuales, zonas, diseños espaciales y para agregar notas o archivos multimedia de la bóveda a un archivo .canvas. Se activa con: crea un canvas, agrega al canvas, pon esto en el canvas."
---

# Canvas

Trata un canvas como un documento JSON Canvas limitado a la bóveda. Mantén las
lecturas en solo lectura y canaliza cada modificación solicitada mediante una
sola transacción recuperable.

Resuelve la raíz del producto instalado a partir de la ubicación propia de esta
skill, no desde la bóveda ni desde el directorio de trabajo actual:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.

## Elige la fuente de sintaxis

Para los detalles del formato, prefiere una skill `json-canvas` de
`kepano/obsidian-skills` instalada por separado. Si no, lee
[references/canvas-spec.md](references/canvas-spec.md). El estándar abierto es
[JSON Canvas 1.0](https://jsoncanvas.org/spec/1.0/).

Usa esta skill para el flujo de trabajo de la bóveda y la seguridad de las
transacciones aunque haya disponible una skill de sintaxis de upstream.

## Alcance

- Resuelve la bóveda del usuario antes de leer. Nunca la derives de los archivos
  del plugin.
- Guarda los tableros en `wiki/canvases/`; usa `wiki/canvases/main.canvas` solo
  como valor predeterminado cuando el usuario no haya nombrado un tablero.
- Trata `wiki/canvases/_index.md` como un catálogo opcional. Agrega un tablero
  nuevo a él en la misma transacción cuando exista un catálogo. Las ediciones de
  nodos o conexiones dentro de un tablero existente no requieren cambiar el
  catálogo.
- El motor de transacciones solo admite la creación y el reemplazo de archivos.
  Un archivo de tablero no se puede eliminar ni renombrar mediante esta skill.
  Explica ese límite ante una solicitud de eliminar o renombrar un archivo y
  devuelve un plan de limpieza aparte; no sustituyas las herramientas de
  archivos del host ni conviertas en silencio un renombrado en una copia.
- Usa rutas relativas a la bóveda en `file` y `background`; rechaza las rutas
  absolutas, el recorrido con `..`, los atajos al directorio personal y las
  rutas que escapen mediante enlaces simbólicos.
- Referencia solo archivos que ya estén dentro de la bóveda o que se creen en la
  misma transacción revisada. Si se detecta una capacidad opcional de captura o
  de multimedia, combínala y consume la ruta relativa a la bóveda que devuelva.
  No asumas un plugin, un comando ni una bitácora de sesión en particular, y no
  descargues ni copies recursos en esta skill.
- Usa nodos `link` para las URL. Acepta solo URL HTTPS; un nodo de enlace no
  da permiso para obtener la página. Crear su JSON no hace ninguna solicitud,
  pero abrirlo en Obsidian puede obtener metadatos Open Graph del host de esa
  URL. Advierte sobre esa salida de red al renderizar y confirma que sea
  aceptable; de lo contrario, usa un nodo de texto que contenga la URL.

## Operaciones de solo lectura

Para las solicitudes de estado o de lista, analiza los archivos `.canvas`
seleccionados e informa los conteos de nodos, las etiquetas de los grupos, los
extremos de conexión rotos y los destinos de archivo relativos a la bóveda que
falten. Si el canvas predeterminado no existe, informa ese hecho y ofrece una
vista previa de su creación; no lo crees durante una solicitud de estado.

## Redacta una modificación

1. Lee el canvas completo y cualquier destino de catálogo. Registra el SHA-256
   esperado de cada uno, o `null` para un archivo que deba estar ausente.
2. Conserva los campos JSON desconocidos y el orden existente de los arreglos. El
   arreglo de nodos sigue el orden z de abajo hacia arriba.
3. Redacta los nodos o conexiones solicitados:
   - Asigna a cada nodo y conexión un ID único. Prefiere un ID hexadecimal
     aleatorio de 16 caracteres en minúsculas y verifica que no esté en uso.
   - Exige valores enteros de `x`, `y`, `width` y `height` para cada nodo.
   - Usa `text`, `file`, `link` o `group` exactamente como los define JSON
     Canvas.
   - Exige que cada `fromNode` y `toNode` haga referencia a un nodo existente o
     recién redactado.
4. Coloca el contenido nuevo con intención. Un grupo es un contenedor visual, no
   un padre. Usa 20 px de relleno interno y 40 px de separación, pasa a una fila
   nueva cuando haga falta y muestra una vista previa de cualquier expansión de
   un grupo.
5. Serializa JSON UTF-8 válido con los arreglos `nodes` y `edges` en el nivel
   superior.

Ejemplos mínimos de nodos:

```json
{
  "nodes": [
    {
      "id": "6f0ad84f44ce9c17",
      "type": "text",
      "text": "# Research map\n\nA concise orientation card.",
      "x": 0,
      "y": 0,
      "width": 400,
      "height": 180
    },
    {
      "id": "a1b2c3d4e5f67890",
      "type": "file",
      "file": "wiki/concepts/Contextual Retrieval.md",
      "x": 460,
      "y": 0,
      "width": 400,
      "height": 240
    }
  ],
  "edges": []
}
```

Usa `file` más un `subpath: "#Heading"` opcional para notas, imágenes, PDF y
otros archivos de la bóveda. Usa `url` solo en un nodo `link`. Escapa los saltos
de línea en las cadenas JSON como `\n`, no como texto literal de barra invertida
más `n`.

## Vista previa y aplicación

Valida antes de mostrar la vista previa:

- El JSON se analiza y usa tipos de nodo admitidos.
- Los ID son únicos y los extremos de las conexiones existen.
- Las dimensiones son enteros positivos.
- Las rutas de archivo y de fondo son seguras, relativas a la bóveda y existen.
- Los nodos nuevos no se superponen ni se desbordan de su grupo solicitado sin
  intención.

Construye un solo paquete `claude-obsidian.transaction.v1` con el tipo de
operación `canvas`. Incluye el canvas y el catálogo en ese mismo paquete cuando
el catálogo cambie. Lee
[operation-transactions.md](../wiki/references/operation-transactions.md) y
luego inspecciona el paquete antes de aplicarlo:

```bash
python3 "$CORE" transaction inspect BUNDLE --vault VAULT
# Tras la revisión, asigna a APPROVAL_SHA256 el approval_sha256 del resultado de inspect.
python3 "$CORE" transaction apply BUNDLE --vault VAULT \
  --approved-plan-sha256 "$APPROVAL_SHA256"
```

Para las ediciones destructivas dentro de un tablero, incluida la
eliminación de nodos o conexiones, obtén el consentimiento explícito después de
presentar la vista previa. Estas ediciones reemplazan el archivo del tablero
mediante el motor de transacciones. Informa el ID de la operación, las rutas
exactas modificadas, el nombre del tablero, los ID de los nodos y las
posiciones finales. No hagas commits en Git.
