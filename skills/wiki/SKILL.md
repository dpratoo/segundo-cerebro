---
name: wiki
description: "Inicializa, adopta y enruta el trabajo de una bóveda de conocimiento de Obsidian separada con el núcleo portátil de claude-obsidian. Úsala para configurar la bóveda o su uso entre proyectos, crear su estructura inicial y elegir el espacio de trabajo o la subskill de wiki correcta. Se activa con: /wiki, configura la wiki, crea la estructura inicial, crea una base de conocimiento, adopta esta bóveda, bóveda de Obsidian, configura un segundo cerebro, wiki persistente."
---

# Orquestación de la wiki

Trata el producto instalado como código y la bóveda del usuario seleccionada como
datos. Nunca uses la raíz del plugin o del producto como bóveda, aunque el
directorio actual sea la copia de trabajo del producto.

Resuelve el núcleo portátil a partir de la instalación de esta skill e invócalo
por su ruta absoluta:

```bash
CORE=/absolute/product/root/scripts/claude-obsidian.py
python3 "$CORE" --help
```

Resuelve una bóveda en este orden: `--vault` explícito,
`CLAUDE_OBSIDIAN_VAULT`, el `.claude-obsidian.json` más cercano y, por último,
una bóveda inicializada no ambigua en el directorio actual o por encima de él.
Falla de forma cerrada cuando la selección falta o es ambigua.

La configuración base no requiere salida de red. No descargues plantillas,
plugins ni contenido remoto a menos que el usuario apruebe por separado los
destinos y el presupuesto.

## Configurar una bóveda

Usa los comandos de configuración deterministas. Ambos son de simulación por
defecto.

Para una bóveda nueva y separada:

```bash
python3 "$CORE" init /absolute/path/to/vault \
  --generated-at <ISO-UTC> --operation-id init-reviewed
python3 "$CORE" init /absolute/path/to/vault \
  --generated-at <ISO-UTC> --operation-id init-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

Para una bóveda de Obsidian existente:

```bash
python3 "$CORE" adopt /absolute/path/to/vault \
  --generated-at <ISO-UTC> --operation-id adopt-reviewed
python3 "$CORE" adopt /absolute/path/to/vault \
  --generated-at <ISO-UTC> --operation-id adopt-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

Antes de `--apply`, muestra la ruta seleccionada y la vista previa de las rutas
que cambian, y luego pasa sin cambios el `approved_plan_sha256` emitido. No uses
`--force` a menos que el usuario haya revisado los conflictos y aprobado de
forma explícita el reemplazo. La configuración no es destructiva por defecto y
no crea ningún remoto de Git del proyecto de origen.

Si el usuario pide una estructura inicial para un dominio específico, establece
primero la base y luego lee [modes.md](references/modes.md). Redacta las páginas
y la configuración adicionales como una sola transacción a nivel de operación.
Nunca modifiques archivos de la bóveda con las herramientas Write/Edit del host
ni con un transporte de Obsidian.

## Enrutar las operaciones

Enruta la intención del usuario sin ampliarla en silencio:

| Intención | Skill |
|---|---|
| Ingerir fuentes proporcionadas | `wiki-ingest` |
| Responder a partir del conocimiento existente de la bóveda | `wiki-query` |
| Guardar un resultado específico de la conversación | `save` |
| Investigar la web pública con un presupuesto | `autoresearch` |
| Revisar la salud de la bóveda | `wiki-lint` |
| Redactar un glosario con citas o consolidar notas que se solapan | `wiki-ingest`, con un alcance revisado de forma explícita |
| Consolidar entradas de la bitácora | `wiki-fold` |
| Trabajar con un canvas | `canvas` |

La consulta es de solo lectura. La persistencia a partir de una consulta debe ser
una operación de guardado explícita y con un alcance propio. Nunca captures una
transcripción ni actualices la caché caliente solo porque terminó una sesión.

## Contrato de modificación

Lee [operation-transactions.md](references/operation-transactions.md) antes de
cualquier estructura inicial o modificación personalizada. Una operación lógica
debe producir un único paquete `claude-obsidian.transaction.v1` inspeccionado y
recuperable. Los agentes en paralelo solo pueden devolver borradores y
evidencia; el orquestador los fusiona y aplica una sola vez. Toda creación o
eliminación de una página canónica incluye, en ese paquete, una actualización
del índice activo o del MOC; actualiza la vista general solo cuando cambió el
panorama estable de alto nivel. El contenido sin procesar de las fuentes es de
solo creación. No hay commits automáticos.

Usa [provenance.md](references/provenance.md) al inicializar o cambiar los
registros de fuentes y de afirmaciones. La evidencia sin respaldo sigue sin
respaldo; nunca inventes una fuente, una cita, una fecha, un localizador ni un
nivel de confianza.

Tras una aplicación exitosa, informa el ID de la operación y las rutas exactas
que cambiaron. Si el usuario quiere de forma explícita un punto de control de
Git, ejecútalo por separado:

```bash
python3 "$CORE" checkpoint OPERATION_ID --vault /absolute/path/to/vault
```

Ante un conflicto, vuelve a leer y reconstruye. Ante una interrupción, usa
`transaction recover`. Reutiliza un ID de operación solo con el paquete idéntico.

## Contexto de instalación

Lee [install-modes.md](references/install-modes.md) cuando importen la
instalación o el comportamiento del host. Los hooks son adaptadores opcionales;
el comportamiento portátil vive en el núcleo y en las skills.

## Referencias condicionales

Lee solo la referencia que necesite la solicitud actual:

- [frontmatter.md](references/frontmatter.md) al definir o adoptar un esquema de
  propiedades;
- [css-snippets.md](references/css-snippets.md) para la personalización visual de
  Obsidian que se haya pedido;
- [git-setup.md](references/git-setup.md) para una configuración explícita de Git
  local o de puntos de control;
- [plugins.md](references/plugins.md) al evaluar integraciones opcionales de
  Obsidian;
- [mcp-setup.md](references/mcp-setup.md) cuando el usuario pide evaluar un
  transporte de lectura externo;
- [rest-api.md](references/rest-api.md) solo cuando el usuario ya tiene o pide de
  forma explícita el adaptador de Local REST API;
- [dataview.md](references/dataview.md) para una configuración opcional de
  Dataview ya existente;
- [knowledge-recipes.md](references/knowledge-recipes.md) para trabajo de
  glosarios con citas o de consolidación;
- [coordination.md](references/coordination.md) para editores externos o varias
  máquinas;
- [native-conformance.md](../../docs/native-conformance.md) para la evidencia
  versionada de aceptación nativa;
- [capacity-and-recovery.md](../../docs/capacity-and-recovery.md) para los
  límites de tamaño o la compactación recuperable de registros heredados;
- [upstream-references.md](../../docs/upstream-references.md) al conciliar
  referencias externas fijadas de sintaxis o de diseño.
- [model-guidance.md](references/model-guidance.md) al evaluar un modelo, cambiar
  un adaptador de generación o validar prompts específicos de un host.

## Pensar, verificar, crecer

Antes de aplicar, haz una sola pausa: observa el estado existente, verifica la
selección de la bóveda y la evidencia, y elige la operación reversible más
pequeña que satisfaga la solicitud. Después, informa la incertidumbre y la
siguiente mejora útil sin ejecutarla de forma automática.
