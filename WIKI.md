# Esquema de la bóveda de claude-obsidian

Este es el esquema compacto, legible para personas, de la bóveda de un usuario.
Los detalles operativos están en las skills y en los contratos ejecutables. El
código del producto y los datos de la bóveda del usuario deben permanecer
separados.

## Estructura de la raíz

```text
vault/
├── .gitignore                  # excluye el estado local de ejecución y de sesión de la bóveda
├── .claude-obsidian.json       # identidad del espacio de trabajo y selección de bóveda
├── inbox/                      # entrada visible de fuentes; nunca se elimina automáticamente
├── .raw/                       # bytes inmutables de las fuentes
│   └── .manifest.json          # metadatos de deltas y direcciones, compatibles con versiones anteriores
├── wiki/                       # conocimiento generado, propiedad del usuario
│   ├── index.md                # catálogo y navegación
│   ├── log.md                  # historial de operaciones completadas, la más reciente primero
│   ├── hot.md                  # contexto reciente acotado, no una transcripción
│   ├── overview.md             # síntesis de alto nivel
│   ├── sources/
│   ├── entities/
│   ├── concepts/
│   ├── questions/
│   ├── canvases/
│   └── meta/ledgers/
│       ├── source-ledger.json
│       └── claim-ledger.json
├── .obsidian/                  # ajustes de Obsidian controlados por el usuario
└── .vault-meta/                # bloqueos, diarios, índices y cola/configuración ignorados
```

El modo LYT, PARA o Zettelkasten puede dirigir las páginas nuevas de otra
manera. Los cambios de modo no migran las notas antiguas ni modifican la
semántica de la evidencia.

## Invariantes de las fuentes

- El contenido de las fuentes existentes bajo `.raw/` nunca se reemplaza.
- `.raw/.manifest.json` son metadatos modificables y solo cambian dentro de la
  misma transacción que la operación que registran.
- La captura de bytes nuevos se direcciona por contenido con SHA-256.
- Un archivo en `inbox/` permanece hasta que el usuario lo elimine. El núcleo
  puede proponer la eliminación, pero nunca la ejecuta.
- Los localizadores remotos usan HTTPS validado. Las credenciales no deben ir en
  URLs, notas de fuente, paquetes, colas ni configuración versionada.

## Frontmatter de las páginas Markdown

Usa YAML plano con claves en plural y fechas `YYYY-MM-DD`:

```yaml
---
type: concept
title: Source-grounded notes
status: developing
created: 2026-07-11
updated: 2026-07-11
tags:
  - knowledge
  - evidence
aliases: []
address: c-000001
---
```

Las propiedades base obligatorias son `type`, `title`, `status`, `created`,
`updated` y `tags`. `aliases` y `address` son opcionales, salvo que una política
configurada de la bóveda los exija.

Tipos de página comunes:

| Tipo | Propósito |
|---|---|
| `source` | Resumen trazable de una identidad de fuente |
| `entity` | Persona, organización, producto, proyecto u otra cosa con nombre |
| `concept` | Idea, marco, mecanismo o definición |
| `question` | Una respuesta acotada con un estado de evidencia visible |
| `comparison` | Contraste basado en criterios con respaldo citado |
| `session` | Resumen, aprobado por el usuario, del contenido seleccionado de la conversación |
| `overview` | Mapa general de un dominio o de una bóveda |
| `meta` | Página de índice, bitácora, caché, convención o mantenimiento |
| `fold` | Resumen consolidado extractivo de entradas identificadas de la bitácora |

`claude_obsidian/page_schema.py` es la única declaración de este vocabulario. La
tabla anterior lo documenta para el lector; el código lee el módulo en lugar de
repetir los valores, y una prueba verifica que ambos coincidan.

`source`, `entity`, `concept`, `question` y `session` son *enrutables*: el
enrutador de metodología puede ubicar una página nueva de ese tipo.
`comparison`, `overview`, `meta` y `fold` son valores válidos de frontmatter y
no son enrutables, porque el producto los crea mediante una operación dedicada
en lugar de organizar una nota nueva.

Los estados comunes son `seed`, `active`, `developing`, `evergreen`,
`answered`, `provisional`, `contested`, `deprecated` y `archived`. Usa solo
estados que los paneles y las convenciones de la bóveda entiendan.

## Sintaxis de Obsidian

- Las referencias internas usan `[[Target]]` o `[[Target|Alias]]`.
- Los encabezados y las referencias a bloque usan `[[Target#Heading]]` y
  `[[Target#^block]]`.
- Las incrustaciones usan `![[Attachment.ext]]`.
- Los destacados usan `> [!type] Title`.
- El código cercado es dato; el texto con forma de enlace que contiene no es una
  conexión del grafo.
- Prefiere los enlaces por nombre base solo cuando el nombre base sea único. Usa
  una ruta relativa a la bóveda cuando los duplicados generen ambigüedad.

No inventes un enlace entrante solo para que el grafo sea simétrico. Agrega
enlaces que ayuden al lector a navegar o a entender una relación.

## Páginas principales

### `wiki/index.md`

El índice es un catálogo curado. Cada destino enlazado debe resolverse. Una
entrada del índice no es evidencia por sí sola. Cada creación o eliminación de
una página canónica actualiza al menos un catálogo activo o MOC en la misma
transacción. Actualiza `wiki/index.md` cuando sea ese catálogo activo; en su
lugar, los MOC específicos de una metodología pueden cumplir el invariante de
navegación.

### `wiki/log.md`

La bitácora registra operaciones lógicas completadas, no escrituras de archivos
individuales. Pon primero la entrada más reciente e incluye el ID de la
operación, el tipo de operación, las páginas principales y un resultado
fundamentado. No reescribas las entradas hijas históricas al crear una
consolidación.

### `wiki/hot.md`

La caché caliente es breve, saneada y útil para la siguiente sesión. Puede
incluir hechos recientes, páginas modificadas, hilos activos y preguntas sin
resolver. No debe contener secretos, transcripciones sin procesar, instrucciones
de herramientas ni afirmaciones que carezcan de la misma calificación que tienen
en las páginas canónicas.

Los hooks pueden leer y emitir este archivo como datos acotados. No lo
actualizan.

### `wiki/overview.md`

La vista general sintetiza la estructura estable y de alto nivel, y enlaza a las
páginas que la respaldan. Cambia con menos frecuencia que la caché caliente.

## Registros de procedencia

El registro de fuentes separa la identidad de la evidencia de la prosa. Cada
fuente registrada puede incluir:

- ID estable y SHA-256;
- localizador de archivo relativo a la bóveda o localizador HTTPS;
- autoridad: `official`, `primary`, `secondary`, `community`, `synthetic` o
  `unknown`;
- clave de independencia;
- marcas de tiempo de obtención y de revisión, y `refresh_due`;
- estado de revisión: `unreviewed`, `active`, `superseded` o `rejected`;
- páginas enlazadas.

El registro de afirmaciones guarda una afirmación falsable, su ubicación en la
nota, los IDs de las fuentes que la respaldan y de las que la contradicen,
confianza, riesgo, estado de revisión y valoración: `accepted`, `provisional`,
`contested`, `unsupported` o `deprecated`.

Las afirmaciones aceptadas necesitan respaldo activo, vigente y no sintético.
Las afirmaciones aceptadas de alto riesgo necesitan dos fuentes independientes.
Conserva las contradicciones y el linaje de las fuentes; no elijas un ganador en
silencio.

## Transacción de operación

Una modificación lógica es un paquete:

```json
{
  "schema": "claude-obsidian.transaction.v1",
  "operation_id": "ingest-example",
  "operation_type": "ingest",
  "expected_hashes": {
    "wiki/sources/Example.md": null
  },
  "writes": [
    {
      "path": "wiki/sources/Example.md",
      "mode": "create",
      "content_file": "drafts/example.md",
      "sha256": "DRAFT_SHA256"
    }
  ],
  "address_requests": [
    {"path": "wiki/sources/Example.md", "prefix": "c"}
  ],
  "source_manifest_updates": {}
}
```

`content` en línea es texto UTF-8. `content_file` puede contener texto o bytes
binarios y debe coincidir con su hash declarado. Las rutas de contenido sin
procesar son de solo creación.

Inspecciona antes de aplicar:

```bash
python3 scripts/claude-obsidian.py transaction inspect <bundle> --vault <vault>
python3 scripts/claude-obsidian.py transaction apply <bundle> --vault <vault> \
  --approved-plan-sha256 <approval_sha256>
```

Usa el `approval_sha256` exacto del resultado de la inspección. Vincula el plan
expandido con la raíz canónica resuelta de la bóveda, de modo que la aprobación
de una bóveda no pueda reutilizarse con otra.

Los agentes en paralelo nunca aplican paquetes ni editan páginas compartidas.
Devuelven a un único orquestador paquetes de borrador con evidencia, rutas de
destino y hashes esperados.

## Contratos de flujo de trabajo

### Ingesta

Una operación de ingesta puede incluir una captura sin procesar de solo
creación, un resumen de la fuente, páginas de entidades y conceptos, registros
de procedencia, actualizaciones del índice o de los MOC, la bitácora, la caché
caliente y la vista general. Cada creación o eliminación canónica actualiza un
índice o MOC activo; los cambios en la vista general siguen condicionados a que
cambie el panorama de alto nivel. Cada afirmación extraída sigue siendo
rastreable hasta la fuente. Los presupuestos del lote acotan la cantidad de
fuentes, el total de bytes, las páginas, los enlaces y el tiempo de trabajo.

### Consulta

La consulta es de solo lectura. Busca el conjunto de evidencia relevante más
pequeño, distingue las afirmaciones aceptadas, provisionales, en disputa, sin
respaldo y desactualizadas, cita páginas de la bóveda y fuentes registradas, e
indica los vacíos. Si el usuario pide conservar la respuesta, invoca una
operación de guardado aparte.

### Guardado

Guarda solo el contenido que el usuario haya seleccionado de forma explícita. No
captures una conversación completa por defecto. La nota guardada, la procedencia
cuando haga falta, el índice, la bitácora y la caché caliente forman una sola
transacción.

### Autoresearch

La investigación tiene una pregunta explícita, una política de fuentes,
consentimiento de salida de red y un presupuesto de detención. Los resultados de
la web se convierten primero en un dosier de investigación con citas.
Fusionarlos en páginas canónicas es una operación aparte, con revisión.

### Lint

El lint es determinista y de solo lectura. Informa de enlaces rotos o ambiguos,
nombres base duplicados, páginas huérfanas, frontmatter faltante, secciones
vacías, entradas de índice obsoletas, errores de configuración o de lectura y
violaciones del contrato de los registros de fuentes y de afirmaciones. Las
reparaciones son propuestas de transacción aparte.

## Seguridad y mantenimiento

- Ejecuta `doctor` para verificar la selección de la bóveda.
- Ejecuta `lint` después de lotes significativos de operaciones.
- Ejecuta `transaction recover` después de una aplicación interrumpida.
- Usa un `checkpoint` explícito solo cuando se quiera historial de Git.
- Mantén las copias de seguridad independientes de los diarios de transacciones.
- Nunca tomes el repositorio del producto, la caché del plugin, la comprobación
  de que existe un archivo de configuración ni una afirmación de una IA como
  prueba de que una capacidad está verificada.
- `configured` significa que los requisitos previos están presentes. `verified`
  exige que pase una comprobación de comportamiento declarada; una comprobación
  de esquema o una autocomprobación no puede promover el estado. Cuando no existe un verificador
  automatizado, la capacidad sigue en estado configurado e informa del motivo
  registrado.

Los contratos ejecutables de `config/` y las pruebas son la fuente de verdad
cuando esta prosa y el comportamiento no coinciden.
