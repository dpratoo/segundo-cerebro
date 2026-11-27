# Convenciones de frontmatter

Conserva el vocabulario de propiedades válido de una bóveda existente. Para una
página genérica nueva de claude-obsidian, usa propiedades YAML planas, listas en
bloque y campos de evidencia explícitos donde correspondan.

## Propiedades comunes

```yaml
---
type: concept
title: "Human-readable title"
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: developing
tags:
  - concept
related:
  - "[[Related page]]"
sources:
  - "[[Source page]]"
claim_ids:
  - claim-example
---
```

Los tipos de página se declaran una sola vez en `claude_obsidian/page_schema.py`
y se documentan en [WIKI.md](../../../WIKI.md). Este archivo repetía antes una
lista más corta que omitía `session` y `fold`, que es la forma en que una bóveda
acaba con valores que uno de los documentos considera no válidos. Los estados se
siguen describiendo en prosa en ambos lugares y quedan fuera del alcance de este
cambio. Una estructura inicial personalizada puede agregar tipos cuando su
esquema esté documentado. `status` suele avanzar por `seed`, `developing`,
`mature` y `evergreen`; conserva los demás valores establecidos en una bóveda
adoptada.

## Propiedades de las fuentes

```yaml
source_type: article
author: ""
date_published: YYYY-MM-DD
url: ""
source_id: ""
sha256: ""
authority: unknown
independence_key: ""
review_state: unreviewed
key_claims:
  - "No claims extracted yet."
```

Los valores permitidos de autoridad y la semántica de la evidencia se definen en
[provenance.md](provenance.md). Un valor ausente queda vacío o como `unknown`;
no fabriques metadatos para completar un formulario.

## Otras propiedades específicas de cada tipo

```yaml
# entity
entity_type: organization
role: ""
first_mentioned: "[[Source page]]"

# concept
complexity: intermediate
domain: ""
aliases:
  - Alternative name

# comparison
subjects:
  - "[[Thing A]]"
  - "[[Thing B]]"
dimensions:
  - cost
  - reliability
assessment: provisional
risk: low

# question
question: "What is being asked?"
assessment: unsupported
risk: low
```

## Reglas

1. Mantén planas las propiedades generadas; no introduzcas mapeos anidados.
2. Escribe las fechas como `YYYY-MM-DD`, salvo que un esquema existente exija
   una marca de tiempo.
3. Usa listas en bloque para las propiedades generadas de varios valores.
4. Pon entre comillas los wikilinks en YAML.
5. Mantén los localizadores externos en los registros de fuentes; usa wikilinks
   para las relaciones internas `related` y `sources`.
6. Actualiza `updated` solo cuando cambie el contenido de la página o su estado
   evaluado.
7. Conserva las propiedades válidas desconocidas durante una edición.
8. No trates una etiqueta de confianza del frontmatter como evidencia; el
   registro de afirmaciones y las fuentes activas vinculadas determinan el
   respaldo.
9. Una etiqueta solo numérica no es válida aunque esté entre comillas. Usa
   `year/2026` o `y2026`, o una propiedad numérica `year`. Conserva los
   metadatos existentes del usuario salvo que se pida explícitamente
   corregirlos. Consulta [Etiquetas de Obsidian](https://obsidian.md/help/tags),
   revisado el 2026-10-17.
