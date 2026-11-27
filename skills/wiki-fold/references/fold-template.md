# Plantilla de página de consolidación

Toda consolidación es extractiva, determinista y usa propiedades planas de
Obsidian.

## Frontmatter

```yaml
---
type: fold
title: "Fold k{K} from {EARLIEST-DATE} to {LATEST-DATE}, n={COUNT}"
fold_id: "fold-k{K}-from-{EARLIEST-DATE}-to-{LATEST-DATE}-n{COUNT}"
batch_exponent: {K}
entry_count: {COUNT}
range_from: "{EARLIEST-CHILD-DATE}"
range_to: "{LATEST-CHILD-DATE}"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
tags:
  - meta
  - fold
  - "fold/k{K}"
status: mature
child_keys:
  - "log-{YYYYMMDD}-001"
  - "log-{YYYYMMDD}-002"
related:
  - "[[log]]"
  - "[[index]]"
---
```

Genera cada `child_key` a partir de la fecha de la entrada más su posición, con
base uno, en el rango seleccionado ordenado de la más antigua a la más reciente.
La misma clave aparece en exactamente una fila del cuerpo. Así se evitan los
objetos YAML anidados y se conserva la biyección entre el frontmatter y la
tabla. El `fold_id` determinista coincide con el nombre del archivo. Que falte
cualquier propiedad obligatoria es un fallo de la simulación.

## Cuerpo

Usa estas secciones en orden.

### Alcance

Un párrafo que indique el nivel, el recuento exacto, el rango de fechas y solo
los temas respaldados por al menos dos entradas hijas.

```markdown
Consolidación de nivel {K} de {COUNT} entradas de la bitácora, desde {FROM} hasta {TO}.
```

### Entradas hijas

Una fila por cada clave hija y entrada de la bitácora. Conserva las entradas
aunque varias filas se refieran a la misma página.

```markdown
## Entradas hijas

| Clave hija | Fecha | Op | Título | Página | Estado de la página | Resumen extractivo |
|---|---|---|---|---|---|---|
| log-20260701-001 | 2026-07-01 | ingest | Fuente de ejemplo archivada | [[Example Source]] | presente | Se agregó una página de ejemplo respaldada por la fuente. |
| log-20260702-002 | 2026-07-02 | save | Decisión de ejemplo registrada | [[Example Decision]] | ausente | Falta la página de origen; el resumen se limita a la entrada de la bitácora. |
```

El resumen es una oración respaldada por la entrada de la bitácora. Usa
`ambiguous in source` o `source missing` en lugar de adivinar.

### Resultados clave

Incluye de tres a siete viñetas extractivas cuando haya respaldo. Cita la clave
hija en cada viñeta y verifica cada número contra la entrada de origen.

```markdown
## Resultados clave

- Se agregó una página de ejemplo respaldada por la fuente. (hija: log-20260701-001)
```

Si ningún resultado tiene respaldo, indícalo de forma explícita.

### Temas entre entradas

Incluye de cero a cuatro viñetas. Cada tema nombra al menos dos claves hijas. Si
ningún patrón tiene respaldo, escribe:

```markdown
## Temas entre entradas

No se identificaron temas entre entradas; las entradas son independientes dentro de este rango.
```

### Contradicciones o correcciones

Conserva los desacuerdos y su estado. Usa `None detected` solo después de revisar
todas las entradas seleccionadas.

### Páginas hijas

Enumera una sola vez cada página de destino presente y única. Esta sección se
deduplica por página; la tabla de Entradas hijas no.

```markdown
## Páginas hijas

- [[Example Source]]

## Relacionado

- [[log]] - entradas de origen
- [[index]] - catálogo de la bóveda
```

## Validación

- `entry_count`, `child_keys` y las filas de la tabla tienen la misma cantidad.
- Cada clave hija es única y aparece exactamente dos veces: en el frontmatter y en
  una fila.
- Cada afirmación numérica es trazable a su entrada hija citada.
- Cada tema cita al menos dos entradas hijas.
- Las páginas ausentes siguen siendo explícitas.
- No se modifica ninguna página hija ni ninguna entrada seleccionada de la
  bitácora.
- El cuerpo de la consolidación es un resumen consolidado, no una narración
  repetida; divide una consolidación inusualmente grande en lugar de imponer un
  objetivo arbitrario de líneas.
