---
name: wiki-fold
description: "Consolida de forma acotada, extractiva y estructuralmente idempotente las entradas recientes de la bitácora de una wiki de Obsidian, con simulación por defecto y una aplicación transaccional opcional. Úsala para compactar la bitácora a mano sin modificar páginas hijas. Se activa con: consolida la bitácora o sus entradas, haz una consolidación, ejecuta wiki-fold, resumen consolidado, aplica la consolidación."
---

# Consolidación extractiva de la bitácora

Crea un resumen consolidado aditivo de las entradas sin procesar de
`wiki/log.md`. Nunca modifiques, muevas ni elimines las entradas hijas ni sus
páginas. No hagas una consolidación de consolidaciones ni dispares una
consolidación de forma automática.

Resuelve el núcleo portátil a partir de la instalación de esta skill. Resuelve
la bóveda del usuario con `--vault` explícito; si no, con
`CLAUDE_OBSIDIAN_VAULT`, luego con la configuración del espacio de trabajo y, por
último, con el descubrimiento desde el directorio actual. Nunca trates la raíz
del plugin o del producto como una bóveda.

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.

Esta skill no necesita salida de red. No llames a servicios externos.

## Seleccionar un rango acotado

Usa el exponente de lote `k` con tamaño `2^k`; por defecto, `k=4`. Un rango
explícito de entradas puede reemplazarlo. Si existen menos entradas de las
solicitadas, informa la diferencia y detente en lugar de consolidar un lote
parcial.

Lee por completo las entradas seleccionadas de la bitácora. Lee las páginas hijas
a las que se hace referencia solo cuando la bitácora no ofrezca contexto
suficiente: objetivo de 0 a 10 lecturas, tope máximo de 15. Las páginas ausentes
siguen siendo registros `page_missing` explícitos.

Deriva el ID estructural solo a partir de los datos de entrada:

```text
fold-k{K}-from-{EARLIEST-DATE}-to-{LATEST-DATE}-n{COUNT}
```

Si `wiki/folds/{FOLD_ID}.md` ya existe, devuelve una operación sin cambios.
Reemplazarlo requiere una solicitud explícita de forzado y una propuesta
`replace` revisada por separado.

## Redactar de forma extractiva

Sigue [fold-template.md](references/fold-template.md). Cada entrada hija de la
bitácora debe tener un `child_key` determinista en el frontmatter y exactamente
una fila correspondiente en la tabla de Entradas hijas. No elimines duplicados de
las entradas hijas por página, aunque la lista final de enlaces de Páginas hijas
sí puede deduplicarse.

Cada resultado debe nombrar su entrada de origen. Cada número debe poder
verificarse en la entrada seleccionada. Un tema entre entradas debe nombrar al
menos dos entradas que contribuyan. Prefiere `ambiguous in source` o
`source missing` a inventar. Cuando una página hija y una entrada de la bitácora
no coincidan, conserva ambas e identifica la discrepancia; la entrada de la
bitácora es la fuente principal de la consolidación.

Ejecuta estas comprobaciones antes de proponer cualquier escritura:

- ID determinista y recuento exacto de entradas;
- biyección entre el frontmatter y la tabla;
- trazabilidad numérica;
- cita de la fuente para cada resultado y tema;
- ningún cambio en una entrada hija, una fuente, el registro de fuentes ni el
  registro de afirmaciones.

Una consolidación no agrega evidencia factual nueva, por lo que no mejora las
valoraciones de las afirmaciones ni crea entradas de fuentes. Informa las
contradicciones que descubras para revisarlas después, en lugar de editar
afirmaciones canónicas.

## Vista previa por defecto

Devuelve el borrador completo de la consolidación, el ID, el rango de entradas
hijas, el presupuesto de lectura y las rutas que se modificarían, sin modificar
la bóveda. Los agentes en paralelo pueden revisar las entradas hijas y devolver
extractos, pero solo el orquestador ensambla la consolidación; los agentes nunca
escriben.

Cuando el usuario diga de forma explícita que se aplique o se ejecute la
consolidación, construye un solo paquete `claude-obsidian.transaction.v1` con
`operation_type: fold`. Lee
[el contrato de transacciones](../wiki/references/operation-transactions.md).
Acopla:

- `wiki/folds/{FOLD_ID}.md` en modo `create` por defecto;
- la entrada de catálogo de la consolidación en `wiki/index.md`;
- una entrada nueva de consolidación al inicio del archivo `wiki/log.md`.

No actualices `wiki/hot.md`. Registra precondiciones SHA-256 para los tres
destinos. No uses Write/Edit del host, escrituras por el transporte de Obsidian,
bloqueos en desuso, commits automáticos ni una aplicación por archivo.

Inspecciona antes de la aplicación única:

```bash
python3 "$CORE" transaction inspect /path/to/fold-bundle.json --vault /path/to/vault
# Tras la revisión, asigna a APPROVAL_SHA256 el approval_sha256 del resultado de inspect.
python3 "$CORE" transaction apply /path/to/fold-bundle.json --vault /path/to/vault \
  --approved-plan-sha256 "$APPROVAL_SHA256"
```

Informa el ID de operación y las rutas exactas modificadas. El paquete y el ID
idénticos son idempotentes. Con el código de salida 75, vuelve a leer y
reconstruye; tras una interrupción, usa `transaction recover`.

El historial de Git es una acción opcional aparte:

```bash
python3 "$CORE" checkpoint OPERATION_ID --vault /path/to/vault
```

Observa todas las entradas seleccionadas, verifica la trazabilidad y los
recuentos y luego haz crecer el resumen consolidado solo a partir de lo que
realmente dicen sus entradas hijas.
