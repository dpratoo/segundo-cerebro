---
name: defuddle
description: "Planifica la extracción opcional con Defuddle y conserva archivos de origen locales ya disponibles con una captura revisada del sistema de archivos. Úsala para preparar una fuente web antes de ingerirla en la wiki. La extracción por red no está disponible hasta verificar un adaptador que imponga los límites. Se activa con: defuddle, limpia esta URL, quita el desorden de la página, Markdown legible de una página web."
---

# Defuddle

Treat Defuddle as an optional external extractor. This package supports inert
URL plans and filesystem capture; it does not ship an enforcing network cleaner.
Cleaning, raw capture, and wiki ingestion are separate operations.

Resolve the installed product root from this skill's own location, never from
the selected vault or process working directory:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.
Upstream flags may be checked in a separately installed `kepano/obsidian-skills`
reference, but do not override this package's privacy and transaction boundary.

## Inert URL plan

Accept HTTPS URLs only. Reject credentials, fragments, controls, sensitive query
parameters, and non-public hosts or IP addresses. Never interpolate a URL into a
shell string. Use one argv element when constructing a plan:

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

## Why execution stops here

The upstream CLI inspected at commit
[`556d74e8c8fd68c49912d4b11a4ae9ec04d7b2b5`](https://github.com/kepano/defuddle/tree/556d74e8c8fd68c49912d4b11a4ae9ec04d7b2b5)
(checked 2026-10-17) follows redirects and enables asynchronous extraction.
Even parsing a local HTML file can request additional resources or third-party
fallbacks. Inspecting argv or obtaining consent for the initial URL cannot
prove that every eventual destination remains approved.

Do not execute the bare CLI against a URL or local HTML under this workflow.
Do not silently substitute a browser, fetcher, proxy, cookies, or another runner.
A future runnable adapter must enforce approved destinations after DNS and on
each redirect, disable uncontrolled async/fallback traffic, constrain proxy
behavior, and bound bytes, time, and subprocess output. It must retain original
and final locators, exact version, approved hosts, capture hash, and mode.
Behavioral tests must prove these limits before execution is offered. Consent
for each destination remains required even with an enforcing adapter.

Do not install tools or claim cleaning, extraction quality, or token savings.
Leave the URL queued, or accept an already available local file. A local file
may be retained as bytes without rendering HTML or running its scripts.

## Reviewable filesystem capture

When the user asks to retain an existing local HTML or Markdown file, place it
in the selected vault's `inbox/` first. Preview and apply the filesystem plan
with a pinned timestamp and operation ID:

```bash
python3 "$CORE" capture plan --vault "$VAULT" "$VAULT/inbox/source.md"
python3 "$CORE" capture apply --vault "$VAULT" "$VAULT/inbox/source.md" \
  --generated-at "$GENERATED_AT" --operation-id "$OPERATION_ID"
# Set APPROVAL_SHA256 to the reviewed approved_plan_sha256 from the dry run.
python3 "$CORE" capture apply --vault "$VAULT" "$VAULT/inbox/source.md" \
  --generated-at "$GENERATED_AT" --operation-id "$OPERATION_ID" \
  --approved-plan-sha256 "$APPROVAL_SHA256" --apply
```

This preserves source bytes in create-only `.raw/captured/` storage. It does not
clean HTML, verify source metadata, or synthesize pages. Inspect the actual
result and record extraction limitations. If already cleaned text is supplied,
retain its known extractor/version and locator without inventing missing fields.
Report the operation ID and exact changed paths. A repeated identical payload
is a no-op; never overwrite immutable raw state.

Use [operation-transactions.md](../wiki/references/operation-transactions.md)
for custom capture drafts. Read or analyze transiently when retention was not
requested. Invoke `wiki-ingest` only as a distinct requested operation.
