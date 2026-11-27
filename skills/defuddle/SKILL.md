---
name: defuddle
description: "Planifica la extracción opcional con Defuddle y conserva archivos de origen locales ya disponibles con una captura revisada del sistema de archivos. Úsala para preparar una fuente web antes de ingerirla en la wiki. La extracción por red no está disponible hasta verificar un adaptador que imponga los límites. Se activa con: defuddle, limpia esta URL, quita el desorden de la página, Markdown legible de una página web."
---

# Defuddle

Trata Defuddle como un extractor externo opcional. Este paquete admite planes de
URL inertes y la captura desde el sistema de archivos; no incluye un limpiador
de red que imponga límites. La limpieza, la captura en bruto y la ingesta en la
wiki son operaciones separadas.

Resuelve la raíz del producto instalado a partir de la ubicación propia de esta
skill, nunca desde la bóveda seleccionada ni desde el directorio de trabajo del
proceso:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.
Las opciones de upstream pueden consultarse en una referencia de
`kepano/obsidian-skills` instalada por separado, pero no deben anular el límite
de privacidad y de transacciones de este paquete.

## Plan de URL inerte

Acepta solo URL HTTPS. Rechaza credenciales, fragmentos, caracteres de control,
parámetros de consulta sensibles y hosts o direcciones IP no públicos. Nunca
interpoles una URL en una cadena de shell. Usa un solo elemento de argv al
construir un plan:

```bash
python3 "$CORE" capture external-plan url "HTTPS_URL"
python3 "$CORE" contracts --verify --capability defuddle --vault "$VAULT"
```

El plan no ejecuta ninguna solicitud de red. Informa el host normalizado, la
salida de red necesaria, la política de redirecciones, la dependencia opcional
y `execute: false`. Un estado `available` significa que no se encontró ningún
ejecutable. Un estado `configured` significa que se descubrió un ejecutable sin
un verificador de comportamiento incluido. Identifica el ejecutable manual y el
motivo informado; nunca lo ejecutes solo porque se encontró.
Nunca cambies la etiqueta `configured` por `verified`.

## Por qué la ejecución se detiene aquí

La CLI de upstream inspeccionada en el commit
[`556d74e8c8fd68c49912d4b11a4ae9ec04d7b2b5`](https://github.com/kepano/defuddle/tree/556d74e8c8fd68c49912d4b11a4ae9ec04d7b2b5)
(revisado el 2026-10-17) sigue redirecciones y habilita la extracción
asíncrona. Incluso analizar un archivo HTML local puede solicitar recursos
adicionales o alternativas de terceros. Inspeccionar argv u obtener
consentimiento para la URL inicial no puede demostrar que todo destino final
siga aprobado.

No ejecutes la CLI directamente contra una URL ni contra un HTML local dentro
de este flujo de trabajo. No sustituyas en silencio un navegador,
una herramienta de descarga, un proxy, cookies ni otro ejecutor. Un futuro
adaptador ejecutable debe imponer los destinos aprobados después del DNS y en
cada redirección, deshabilitar el tráfico asíncrono o de alternativa no
controlado, restringir el comportamiento del proxy y acotar los bytes, el tiempo
y la salida de los subprocesos. Debe conservar los localizadores original y
final, la versión exacta, los hosts aprobados, el hash de la captura y el modo.
Las pruebas de comportamiento deben demostrar estos límites antes de ofrecer la
ejecución. El consentimiento para cada destino sigue siendo obligatorio incluso
con un adaptador que imponga los límites.

No instales herramientas ni afirmes una limpieza, una calidad de extracción o un
ahorro de tokens. Deja la URL en cola o acepta un archivo local ya disponible.
Un archivo local puede conservarse como bytes sin renderizar el HTML ni ejecutar
sus scripts.

## Captura revisable del sistema de archivos

Cuando el usuario pida conservar un archivo HTML o Markdown local existente,
colócalo primero en el `inbox/` de la bóveda seleccionada. Muestra una vista
previa del plan del sistema de archivos y aplícalo con una marca de tiempo y un
ID de operación fijos:

```bash
python3 "$CORE" capture plan --vault "$VAULT" "$VAULT/inbox/source.md"
python3 "$CORE" capture apply --vault "$VAULT" "$VAULT/inbox/source.md" \
  --generated-at "$GENERATED_AT" --operation-id "$OPERATION_ID"
# Define APPROVAL_SHA256 con el approved_plan_sha256 revisado de la simulación.
python3 "$CORE" capture apply --vault "$VAULT" "$VAULT/inbox/source.md" \
  --generated-at "$GENERATED_AT" --operation-id "$OPERATION_ID" \
  --approved-plan-sha256 "$APPROVAL_SHA256" --apply
```

Esto conserva los bytes de la fuente en el almacenamiento `.raw/captured/` de
solo creación. No limpia el HTML, no verifica los metadatos de la fuente ni
sintetiza páginas. Inspecciona el resultado real y registra las limitaciones de
la extracción. Si se entrega texto ya limpio, conserva su extractor y versión
conocidos y su localizador, sin inventar los campos que falten. Informa el ID de
la operación y las rutas exactas modificadas. Una carga idéntica repetida no
hace nada; nunca sobrescribas el estado en bruto inmutable.

Usa [operation-transactions.md](../wiki/references/operation-transactions.md)
para los borradores de captura personalizados. Lee o analiza de forma
transitoria cuando no se haya pedido conservar. Invoca `wiki-ingest` solo como
una operación distinta solicitada.
