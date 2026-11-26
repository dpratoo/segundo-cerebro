---
name: wiki-lint
description: "Hace una revisión de salud determinista y de solo lectura de una wiki de Obsidian. Informa sobre grafo, enlaces, frontmatter, registro de procedencia, secciones vacías e índice obsoleto; no razona en sentido amplio ni repara archivos. Se activa con: lint, revisa la salud de la bóveda, audita la salud de la wiki, busca páginas huérfanas, busca enlaces rotos, audita el frontmatter, audita la procedencia, audita la wiki."
---

# Lint the wiki

Use the portable lint engine as the source of truth. Lint observes vault state;
it does not create reports, dashboards, canvases, stubs, or fixes.

Resolve the installed product root from this skill's own location, not from the
vault or current working directory:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.

## Run

Resolve the user vault, then run one of:

```bash
python3 "$CORE" lint --vault "$VAULT"
python3 "$CORE" lint --vault "$VAULT" --format markdown
python3 "$CORE" lint --vault "$VAULT" --exclude "wiki/scratchpad/*"
```

The repeatable `--exclude GLOB` flag scopes a path (for example a scratchpad
folder) out of page, link-resolution, orphan, frontmatter, empty-section, and
stale-index scanning.

Use `--strict` only when a nonzero exit for findings is useful in automation.
The command remains read-only either way.

The deterministic parser understands Obsidian wikilinks and embeds, Markdown
links, aliases, heading and block fragments, escaped aliases, and code fences.
It skips dot-prefixed directories by default, mirroring Obsidian's own
indexer. Link resolution honors `.gitignore` files inside the vault (no `git`
subprocess): when a link is ambiguous between a page and a gitignored file
such as a build artifact, the gitignored candidate is dropped.
It reports such categories as dead or ambiguous links, orphan pages, required
frontmatter gaps (including `title`), empty sections, stale index entries, and
source/claim ledger contract violations. Report only the
checks and counts present in its output; do not claim that it performed
semantic, stylistic, or prose-level contradiction analysis when it did
not.

## Explain findings

1. Preserve the engine's paths, line numbers, targets, categories, and counts.
2. Group findings by likely impact: broken navigation, ambiguous resolution,
   metadata quality, then maintainability.
3. Explain that an orphan may be intentional and an ambiguous basename needs a
   path-qualified link; do not infer intent from the finding alone.
4. Treat allowlisted findings as policy, not as proof that the target exists.
5. Separate deterministic facts from suggested remediation.

Do not write the Markdown rendering into the vault. Return it in chat or stdout.

## Repair is a separate operation

Never auto-fix a lint result. After the user chooses specific findings to
repair:

1. Re-read each target and record its expected SHA-256.
2. Draft only the selected changes; do not delete or merge pages without
   explicit consent.
3. Build one repair bundle with a new operation ID.
4. Inspect the bundle and show exact changed paths.
5. Apply only after that separate review.
6. Re-run lint read-only and compare the relevant findings.

Follow the [operation transaction contract](../wiki/references/operation-transactions.md).
Lint itself never applies that transaction and never commits Git.

## Checkpoint

Observe the deterministic report, think about root causes rather than finding
count, verify proposed repairs against current hashes, and grow by improving the
workflow that produced repeated findings.
