# Especificación JSON de Canvas de Obsidian

Los archivos de Canvas son JSON con dos claves de nivel superior: `nodes` (arreglo) y `edges` (arreglo).
Obsidian los lee y los escribe como archivos JSON UTF-8 con la extensión `.canvas`.

Esta referencia se alinea con la [especificación abierta JSON Canvas 1.0](https://jsoncanvas.org/spec/1.0/). Todas las estructuras admiten campos adicionales arbitrarios (`[key: string]: any`) por compatibilidad futura. Obsidian conserva los campos desconocidos al leer y escribir archivos canvas.

**Formato de los ID**: JSON Canvas 1.0 exige que el ID de cada nodo y conexión
sea una cadena única; no prescribe una longitud ni un conjunto de caracteres.
Como convención del producto, las nuevas modificaciones de esta skill prefieren
ID aleatorios de 16 caracteres hexadecimales en minúsculas (por ejemplo,
`"a1b2c3d4e5f67890"`) y verifican que sean únicos. Los ID descriptivos de los
ejemplos más largos de abajo son solo etiquetas de legibilidad, no la regla de
generación.

---

## Sistema de coordenadas

```
        x increases →
   ┌─────────────────────────────────
   │  (-920, -2400)      (0, -2400)
   │
y  │  (-920, 0)          (0, 0) ← origin
↓  │
   │  (-920, 540)        (500, 540)
```

- El **origen** (0, 0) es el centro de la vista del canvas.
- **x aumenta hacia la derecha.** x negativa = a la izquierda del centro.
- **y aumenta hacia abajo.** y negativa = por encima del centro.
- `x` e `y` de un nodo son la **esquina superior izquierda** del nodo, no el centro.
- Al abrirlo por primera vez, Obsidian desplaza la vista para que quepan todos los nodos.

---

## Tipos de nodo

### Nodo de texto

Muestra contenido Markdown como una tarjeta con estilo.

```json
{
  "id": "text-title-4821",
  "type": "text",
  "text": "# Heading\n\nParagraph with **bold** and `code`.",
  "x": -400,
  "y": -300,
  "width": 400,
  "height": 120,
  "color": "6"
}
```

- `text`: cadena Markdown. Usa `\n` para los saltos de línea.
- Tamaño mínimo legible: width ≥ 200, height ≥ 60.
- `color` es opcional. Omítelo para el valor predeterminado (sin color).

---

### Nodo de archivo

Muestra en línea una imagen, un PDF, una nota Markdown u otro archivo de la bóveda.

```json
{
  "id": "img-cover-7823",
  "type": "file",
  "file": "_attachments/images/example.png",
  "x": -900,
  "y": -100,
  "width": 420,
  "height": 236
}
```

- `file`: **ruta relativa a la bóveda** (no absoluta, no `~/`).
- Admitidos: `.png` `.jpg` `.webp` `.gif` `.pdf` `.md` `.canvas`
- Para archivos `.md`: se muestra como una tarjeta de vista previa.
- Para archivos `.pdf`: se muestra la primera página como vista previa.
- Un nodo de archivo puede incluir el campo opcional `color`, como todo nodo
  genérico. Omítelo para usar la apariencia predeterminada.

---

### Nodo de grupo (zona)

Una región rectangular con etiqueta. No recorta ni contiene nodos. Es una guía visual.
Los nodos colocados "dentro" de un grupo solo están posicionados dentro de su caja delimitadora.

```json
{
  "id": "zone-branding-3391",
  "type": "group",
  "label": "Brand Identity",
  "x": -920,
  "y": -880,
  "width": 1060,
  "height": 290,
  "color": "6",
  "background": "_attachments/images/grid-bg.png",
  "backgroundStyle": "cover"
}
```

- `label`: se muestra en la parte superior de la caja del grupo.
- `color`: colorea el borde y la etiqueta del grupo.
- `background` *(opcional)*: ruta relativa a la bóveda de una imagen de fondo para el grupo.
- `backgroundStyle` *(opcional)*: cómo se muestra el fondo.
  - `"cover"`: llena el grupo y recorta si hace falta (comportamiento casi predeterminado)
  - `"ratio"`: conserva la proporción y cabe dentro del grupo
  - `"repeat"`: repite la imagen en mosaico
- Los grupos no afectan el diseño automático: son contenedores puramente visuales.

---

### Nodo de enlace

Muestra una URL web como una tarjeta de vista previa incrustada.

```json
{
  "id": "link-karpathy-2233",
  "type": "link",
  "url": "https://github.com/karpathy",
  "x": 200,
  "y": -300,
  "width": 400,
  "height": 120
}
```

- `url`: debe ser una URL `https://` válida.
- Obsidian obtiene la vista previa Open Graph (título, descripción, miniatura).
- Escribir el nodo en sí no realiza ninguna solicitud. Abrirlo o renderizarlo en
  Obsidian puede contactar al host de la URL, así que primero advierte sobre esa
  salida de red y usa un nodo de texto cuando no sea aceptable obtener la vista
  previa.

---

## Conexiones

Conexiones entre nodos. Suelen estar vacías en los tableros de inspiración.

```json
{
  "id": "e-hub-cidx",
  "fromNode": "hub",
  "fromSide": "right",
  "fromEnd": "none",
  "toNode": "c-idx",
  "toSide": "left",
  "toEnd": "arrow",
  "label": "concepts",
  "color": "5"
}
```

**Campos obligatorios**: `id`, `fromNode`, `toNode`. Todo lo demás es opcional.

- `fromNode` / `toNode`: ID de los nodos de origen y de destino.
- `fromSide` / `toSide` *(opcional)*: `"top"` `"bottom"` `"left"` `"right"`. Si se omiten, Obsidian calcula automáticamente el mejor lado según las posiciones relativas de los nodos.
- `fromEnd` *(opcional)*: remate en el lado de origen. Por defecto es `"none"`. Valores: `"none"` | `"arrow"`.
- `toEnd` *(opcional)*: remate en el lado de destino. **Por defecto es `"arrow"`**: observa el valor predeterminado asimétrico respecto de `fromEnd`. Valores: `"none"` | `"arrow"`.
- `label` *(opcional)*: texto que se muestra en la conexión.
- `color` *(opcional)*: la misma paleta de colores que los nodos (`"1"` a `"6"` o hexadecimal).

La mayoría de las conexiones representan relaciones dirigidas, así que los valores predeterminados asimétricos (`fromEnd: "none"`, `toEnd: "arrow"`) producen una sola flecha que apunta del origen al destino sin especificar nada de forma explícita.

---

## Referencia de colores

| Código | Color | Hex (aprox.) | Uso |
|------|-------|-------------|----------|
| `"1"` | Rojo / Tomate | #e03e3e | Advertencias, archivado |
| `"2"` | Naranja | #d09035 | Trabajo activo |
| `"3"` | Amarillo / Dorado | #d0a023 | En curso, notas |
| `"4"` | Verde / Verde azulado | #448361 | Contenido, fuentes |
| `"5"` | Azul / Cian | #3ea7d3 | Navegación, información |
| `"6"` | Púrpura / Violeta | #9063d2 | Título, identidad |

Omite `color` por completo para el valor predeterminado (sin color de borde, etiqueta transparente).

---

## Pautas de tamaño de imágenes

Calcula a partir de las dimensiones reales de la imagen con PIL o `identify`:

```bash
python3 -c "from PIL import Image; img=Image.open('path.png'); print(img.width, img.height)"
# o
identify -format '%w %h' path.png
```

| Relación de aspecto | Condición | Ancho en el canvas | Alto en el canvas |
|-------------|-----------|-------------|--------------|
| 16:9 (ancho) | relación de 1.6 a 2.0 | 420 | 236 |
| 2:1 (ultraancho) | relación > 2.0 | 440 | 220 |
| 4:3 | relación de 1.2 a 1.6 | 380 | 285 |
| 1:1 (cuadrado) | relación de 0.9 a 1.1 | 280 | 280 |
| 3:4 | relación de 0.6 a 0.9 | 240 | 320 |
| 9:16 (vertical) | relación < 0.6 | 200 | 356 |
| PDF | cualquiera | 400 | 520 |
| Desconocida | alternativa | 320 | 240 |

---

## Pseudocódigo de posicionamiento automático

```
function place_node(canvas, zone_label, new_w, new_h):
  zone = find group node where label == zone_label
  padding = 20

  if zone not found:
    max_y = max(n.y + n.height for n in canvas.nodes) + 60
    return (-400, max_y)

  # Nodos visualmente dentro de la zona
  inside = [n for n in canvas.nodes
            if n.type != 'group'
            and zone.x <= n.x < zone.x + zone.width
            and zone.y <= n.y < zone.y + zone.height]

  if inside is empty:
    return (zone.x + padding, zone.y + padding)

  # Punto más a la derecha de la zona
  rightmost = max(n.x + n.width for n in inside)
  next_x = rightmost + 40

  if next_x + new_w > zone.x + zone.width - padding:
    # Desborde → nueva fila
    bottom_of_row = max(n.y + n.height for n in inside)
    return (zone.x + padding, bottom_of_row + padding)

  # Misma fila
  row_y = min(n.y for n in inside)  # alinear con la parte superior de la fila existente
  return (next_x, row_y)
```

---

## Ejemplo completo: canvas de dos zonas

```json
{
  "nodes": [
    {
      "id": "title-0001",
      "type": "text",
      "text": "# Brand Reference\n\n**AI Marketing Hub** visual assets",
      "x": -920, "y": -2440, "width": 560, "height": 180, "color": "6"
    },
    {
      "id": "zone-logos",
      "type": "group",
      "label": "Logos & Icons",
      "x": -920, "y": -2200, "width": 1800, "height": 320, "color": "6"
    },
    {
      "id": "img-logo-pro",
      "type": "file",
      "file": "_attachments/images/example.png",
      "x": -900, "y": -2180, "width": 420, "height": 236
    },
    {
      "id": "img-icon-free",
      "type": "file",
      "file": "_attachments/images/example-icon.png",
      "x": -440, "y": -2180, "width": 280, "height": 280
    },
    {
      "id": "zone-covers",
      "type": "group",
      "label": "Skill Covers",
      "x": -920, "y": -1820, "width": 1800, "height": 340, "color": "3"
    },
    {
      "id": "img-seo",
      "type": "file",
      "file": "_attachments/images/example-cover.png",
      "x": -900, "y": -1800, "width": 420, "height": 236
    }
  ],
  "edges": []
}
```

---

## Errores comunes

- **Formato de ruta incorrecto**: usa `_attachments/images/file.png`, no una ruta absoluta del host
- **Colisión de ID**: lee siempre los ID existentes antes de generar uno nuevo
- **Confusión con y negativa**: `y: -2400` está POR ENCIMA de `y: -1000` (más negativo = más arriba)
- **El grupo no recorta**: colocar un nodo "dentro" de un grupo es solo posicionarlo dentro de la caja delimitadora del grupo: no hay relación de padre e hijo en el JSON
- **Falta de height en los nodos de texto**: Obsidian mostrará el texto, pero puede recortarlo si height es demasiado pequeño. Usa height ≥ líneas de contenido × 24.
