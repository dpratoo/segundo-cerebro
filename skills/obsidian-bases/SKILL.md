---
name: obsidian-bases
description: "Explica, redacta y valida archivos .base de Obsidian Bases con filtros, fórmulas, propiedades, resúmenes y vistas de tabla, tarjetas, lista o kanban (esta última según la versión). Úsala para Obsidian Bases, vistas de la bóveda tipo base de datos, tablas dinámicas, listas de lectura, seguimiento de tareas, filtros, fórmulas, resúmenes y ediciones de archivos .base."
---

# Obsidian Bases

Úsala como referencia compacta de flujo de trabajo y de sintaxis alternativa.
Para campos y funciones detallados o que dependen de la versión, prefiere una
skill `obsidian-bases` de `kepano/obsidian-skills` instalada por separado y
después la [sintaxis oficial de Bases](https://help.obsidian.md/bases/syntax)
vigente.

Responde las preguntas de diseño y de sintaxis en modo de solo lectura. Para una
edición solicitada de un archivo `.base`, resuelve la bóveda del usuario y usa
una sola transacción inspeccionada; nunca escribas el archivo directamente.

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

## Flujo de trabajo

1. Inspecciona las propiedades de notas representativas y cualquier archivo
   `.base` existente.
2. Define el filtro más pequeño que seleccione las notas previstas.
3. Agrega fórmulas solo para los valores que deban calcularse.
4. Elige las vistas y el orden de visualización. No asumas que un tipo de vista
   o una opción es compatible con la versión de Obsidian del usuario ni con sus
   complementos instalados.
5. Valida el YAML, el uso de comillas en las expresiones, los nombres de
   propiedades, las referencias a fórmulas y el manejo de valores nulos.
6. Muestra una vista previa del archivo completo y del conjunto de resultados
   esperado antes de una modificación.
7. Si se pidió una edición, lee
   [operation-transactions.md](../wiki/references/operation-transactions.md),
   mantén el archivo `.base` dentro de `wiki/` y construye un solo paquete
   `claude-obsidian.transaction.v1` con `operation_type: base`. Inspecciónalo,
   define `APPROVAL_SHA256` con el `approval_sha256` devuelto solo después de
   revisarlo y aplícalo una sola vez:

   ```bash
   python3 "$CORE" transaction inspect "$BUNDLE" --vault "$VAULT"
   python3 "$CORE" transaction apply "$BUNDLE" --vault "$VAULT" \
     --approved-plan-sha256 "$APPROVAL_SHA256"
   ```
8. Registra la validación estática por separado del renderizado nativo de
   Obsidian. Sigue [el procedimiento de conformidad](../../docs/native-conformance.md)
   cuando el comportamiento de la aplicación no se pueda verificar localmente.
   Nunca marques como probada una salida que no se observó.

## Límite de versiones

Revisado el 2026-10-17 frente a la [documentación oficial de vistas](https://obsidian.md/help/bases/views).
Tabla y tarjetas requieren 1.9+, lista requiere 1.10+ y el kanban nativo
requiere 1.14+. Mapa requiere el complemento Maps. Estas son versiones mínimas
documentadas, no versiones ejercitadas por las pruebas sin conexión de este
paquete. En una aplicación más antigua, conserva una alternativa de tabla
ordinaria. Conserva los campos de vista existentes desconocidos.

## Esquema compacto

Los archivos `.base` son YAML. Las claves comunes de nivel superior son
`filters`, `formulas`, `properties`, `summaries` y `views`.

```yaml
filters:
  and:
    - file.inFolder("wiki")
    - 'status != "archived"'

formulas:
  status_label: 'if(status == "mature", "Ready", "Review")'

properties:
  status:
    displayName: "Status"

views:
  - type: table
    name: "Wiki pages"
    order:
      - file.name
      - type
      - status
      - updated
      - formula.status_label
```

Los filtros globales se aplican a todas las vistas. Una vista también puede
definir sus propios `filters`. Los objetos de filtro recursivos usan uno de
`and`, `or` o `not` en cada nivel.

```yaml
filters:
  or:
    - file.hasTag("concept")
    - and:
        - file.hasTag("source")
        - 'status == "active"'
```

Usa las propiedades de las notas por su nombre, los metadatos del archivo como
`file.name`, `file.path`, `file.folder`, `file.ext`, `file.ctime`, `file.mtime`
o `file.tags`, y las propiedades calculadas como `formula.<name>`.

## Reglas de fórmulas y YAML

- Pon entre comillas las expresiones que contengan operadores, dos puntos o
  comillas de cadena anidadas.
- Protege las propiedades que pueden ser nulas con `if()`.
- La resta de fechas tiene descripciones contradictorias en las fuentes
  actuales. Trata los ejemplos de la sección de fechas de más abajo como
  candidatos de compatibilidad no verificados y prueba las versiones de la
  aplicación que admite el usuario antes de confiar en el resultado.
- Define cada `formula.<name>` antes de referenciarla en una vista o en la
  configuración de visualización de propiedades.
- No traslades a una Base claves exclusivas de Dataview, como `from` o `where`.
- No inventes propiedades ausentes en las notas seleccionadas sin explicar que
  la columna resultante estará vacía.

## La aritmética de fechas necesita evidencia nativa

La [sintaxis de la Ayuda](https://obsidian.md/help/bases/syntax) revisada el
2026-10-17 todavía describe las diferencias de fechas en milisegundos. El
[registro de cambios de la 1.9.3](https://obsidian.md/changelog/2025-06-26-desktop-v1.9.3/)
oficial describe una Duration, y la skill de upstream fijada también usa un
campo Duration. Los extractos registrados de los
[tipos de la API en el commit revisado](https://github.com/obsidianmd/obsidian-api/blob/9abd9605ce081383674aae1ed111c456edde0688/obsidian.d.ts)
no incluyen una definición de Duration, por lo que no se citan para ninguna de
las dos lecturas.
Ninguna observación en la aplicación nativa resuelve ese desacuerdo en esta
actualización.

Estas expresiones en milisegundos que se conservan son candidatas para una
prueba aislada, no una garantía de compatibilidad:

```yaml
formulas:
  age_days: '((now() - file.ctime) / 86400000).round(0)'
  days_until: 'if(due_date, ((date(due_date) - today()) / 86400000).round(0), "")'
```

Compara la resta y la división directas, el campo de días de Duration y la resta
explícita con `number(date)` usando valores de un día, de varios meses,
negativos y ausentes. Registra la versión de la aplicación, la zona horaria, la
expresión, el valor y el tipo reales, y los errores usando
[native-conformance.md](../../docs/native-conformance.md). No reescribas las
fórmulas existentes ni afirmes que algún candidato es correcto antes de esa
comprobación.

## Vistas adicionales

Ejemplos de tarjetas y de lista:

```yaml
views:
  - type: cards
    name: "Reading list"
    order:
      - file.name
      - author
      - status
  - type: list
    name: "Quick list"
    order:
      - file.name
      - status
```

En Obsidian 1.14+, agrupa un kanban por una propiedad de nota existente y
editable:

```yaml
filters:
  and:
    - file.inFolder("wiki")
    - 'file.ext == "md"'
views:
  - type: kanban
    name: "Page status"
    groupBy:
      property: note.status
      direction: ASC
    groupOrder:
      - seed
      - developing
      - mature
      - evergreen
      - null
    order:
      - file.name
      - status
```

`groupOrder` enumera los grupos visibles en el orden de visualización. Si falta
`groupOrder`, se muestran todos los grupos con el orden de `groupBy`; una lista
vacía oculta todos los grupos. `null` incluye las páginas sin el valor
agrupado. Agregar un grupo vacío no crea una nota. Mover tarjetas de forma
nativa puede cambiar una propiedad de la nota, y agrupar por `file.folder` puede
mover archivos; los agentes deben seguir usando transacciones revisadas para las
modificaciones de la bóveda. Una fórmula u otra propiedad de archivo de solo
lectura no sirve para un tablero de estados editable. Consulta la
[vista Kanban](https://obsidian.md/help/bases/views/kanban).

Incrusta una Base, o una vista con nombre, en una nota Markdown:

```markdown
![[Dashboard.base]]
![[Dashboard.base#Wiki pages]]
```

Tras una edición aplicada, informa el ID de la operación, la ruta exacta
modificada, la validación realizada y todo lo que aún requiera renderizarse en
Obsidian. No hagas commits en Git.
