---
name: wiki-mode
description: "Lee o configura la metodología de organización de la bóveda y sugiere destinos para el conocimiento que se planea crear con Generic, LYT, PARA o Zettelkasten. Esta skill no guarda contenido ni migra notas. Se activa con: modo wiki, modo de metodología, cuál es el modo de mi bóveda, define el modo de la bóveda, cambia a PARA, usa LYT, configura Zettelkasten, cambia el modo, configura el modo, enrutamiento por metodología."
---

# Enrutar según la metodología de la bóveda

Esta skill devuelve sugerencias de organización. No escribe páginas de
conocimiento ni mueve notas existentes. Si `.vault-meta/mode.json` no existe,
usa `generic`. Si el archivo existe pero no es válido, falla de forma cerrada y
repáralo mediante una operación de configuración revisada antes de sugerir
rutas; nunca uses en silencio Genérico en lugar de una configuración de usuario
corrupta.

Resuelve la raíz del producto instalado a partir de la ubicación de esta skill,
no de la bóveda ni del directorio de trabajo actual:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
MODE_HELPER="$PRODUCT_ROOT/scripts/wiki-mode.py"
test -f "$CORE" && test -f "$MODE_HELPER"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.

## Leer y enrutar con seguridad

Selecciona siempre la bóveda de forma explícita:

```bash
python3 "$MODE_HELPER" --vault "$VAULT" get
python3 "$MODE_HELPER" --vault "$VAULT" config
python3 "$MODE_HELPER" --vault "$VAULT" route concept "Concept name"
python3 "$MODE_HELPER" --vault "$VAULT" route source "Source title"
```

El script auxiliar valida la bóveda seleccionada, confina las rutas, sanea los nombres e
imprime solo una sugerencia. Una skill que lo llame puede anular la sugerencia
cuando el usuario aporta un proyecto, un área, un MOC o una nota padre más
específicos, pero aun así debe aplicar sus escrituras finales mediante una sola
transacción de operación.

| Modo | Intención de enrutamiento |
|---|---|
| `generic` | Carpetas basadas en el tipo, como fuentes, entidades, conceptos y sesiones. |
| `lyt` | Notas atómicas bajo `wiki/notes/`, conectadas mediante MOC. |
| `para` | Proyectos, Áreas, Recursos o Archivo, elegidos según la capacidad de acción. |
| `zettelkasten` | Notas atómicas planas con identificadores ordenables por tiempo y resistentes a colisiones, y enlaces explícitos. |

Usa las plantillas como guía estructural: [nota atómica de LYT](templates/lyt/atomic-template.md),
[MOC de LYT](templates/lyt/moc-template.md), [área de PARA](templates/para/area-template.md),
[proyecto de PARA](templates/para/project-template.md),
[recurso de PARA](templates/para/resource-template.md) o
[nota atómica de Zettelkasten](templates/zettel/atomic-template.md). Usan valores
canónicos de `type` de `claude_obsidian/page_schema.py` y una propiedad plana
aparte, `methodology_role`:

| Plantilla | Tipo | Rol en la metodología |
|---|---|---|
| Nota atómica de LYT | `concept` | `atomic` |
| MOC de LYT | `meta` | `moc` |
| Área de PARA | `concept` | `area` |
| Proyecto de PARA | `entity` | `project` |
| Colección de recursos de PARA | `concept` | `resource` |
| Nota atómica de Zettelkasten | `concept` | `zettel` |

Una plantilla de recursos describe una colección temática. Usa `source` en su
lugar cuando la página nueva represente una fuente capturada concreta. El rol de
metodología no agrega un tipo al enrutador: pasa el tipo canónico y respeta el
destino elegido de proyecto, área o MOC. Los MOC estructurales usan un destino
explícito; `meta` no es un tipo enrutable para notas nuevas. Las páginas
existentes del usuario, los vocabularios de tipos personalizados y las consultas
de Dataview guardadas permanecen sin cambios. Cualquier migración solicitada
necesita su propio plan revisado; cambiar de modo nunca reescribe las notas
existentes.

## Cambiar el modo

Un cambio de modo es una sola operación de configuración, primero como
simulación:

1. Lee el `.vault-meta/mode.json` actual, o parte de la configuración
   predeterminada del script auxiliar cuando no existe.
2. Valida que el modo solicitado sea exactamente `generic`, `lyt`, `para` o
   `zettelkasten`. Conserva los demás ajustes específicos del modo.
3. Elige y conserva una marca de tiempo UTC fija y un ID de operación para ambos
   comandos.
4. Muestra una vista previa de la transacción de configuración canónica; el
   comando registra el hash actual del destino y limita la escritura a
   `.vault-meta/mode.json`:

   ```bash
   python3 "$CORE" mode set "$MODE" --vault "$VAULT" \
     --generated-at "$GENERATED_AT" --operation-id "$OPERATION_ID"
   ```

5. Muestra el modo anterior, el modo nuevo, la ruta exacta modificada y la vista
   previa completa. Copia su `approved_plan_sha256` solo después de revisarla.
6. Aplica regenerando ese mismo plan vinculado a la bóveda:

   ```bash
   python3 "$CORE" mode set "$MODE" --vault "$VAULT" \
     --generated-at "$GENERATED_AT" --operation-id "$OPERATION_ID" \
     --approved-plan-sha256 "$APPROVAL_SHA256" --apply
   ```

Sigue el [contrato de transacciones de operación](../wiki/references/operation-transactions.md).
No uses la acción `set` heredada de escritura directa de `scripts/wiki-mode.py`
ni un script de instalación para eludir este flujo.

Cambiar el modo afecta solo al enrutamiento de las operaciones futuras. Nunca
crees carpetas en bloque, muevas notas, reescribas wikilinks ni migres páginas
existentes como efecto secundario. Si más adelante se pide una migración,
planifícala y revísala como una operación distinta, con sus propios hashes y su
propia transacción.

## Punto de control

Observa la estructura actual del usuario, piensa cómo busca sus notas y actúa
sobre ellas, verifica unas cuantas rutas propuestas antes de cambiar la
configuración y crece revisando el modo solo cuando aparezca una fricción real de
organización.
