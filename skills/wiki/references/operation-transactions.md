# Transacciones de operación

Usa esta referencia siempre que una skill vaya a cambiar el estado de la bóveda.

## Contrato

Una operación lógica produce un único paquete de transacción versionado y una
única aplicación recuperable. Los agentes en paralelo pueden leer y redactar, pero solo
el orquestador aplica las modificaciones de la bóveda.

Resuelve la raíz del producto instalado a partir de la ubicación de la propia
skill que la invoca, no del directorio de trabajo de la bóveda del usuario:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

Nunca uses en trabajo nuevo el script auxiliar obsoleto `wiki-lock.sh`, que bloquea
archivo por archivo. Nunca hagas commit desde un hook genérico del ciclo de
vida.

## Flujo de trabajo

1. Resuelve una bóveda de usuario. Prefiere `--vault`, luego
   `CLAUDE_OBSIDIAN_VAULT`, luego `.claude-obsidian.json` y, por último, el
   descubrimiento inequívoco del directorio actual.
2. Lee cada destino esperado y registra su SHA-256, o `null` cuando deba estar
   ausente.
3. Haz que los agentes devuelvan borradores y evidencia. Los agentes no editan
   el estado compartido de la bóveda.
4. Construye un único paquete JSON `claude-obsidian.transaction.v1`.
5. Ejecuta `python3 "$CORE" transaction inspect BUNDLE --vault VAULT`.
6. Muestra al usuario las propuestas destructivas, externas o de fusión
   canónica antes de aplicarlas.
7. Pasa el `approval_sha256` exacto del resultado de la inspección, que vincula
   el plan expandido con la raíz canónica resuelta de la bóveda y no puede
   reutilizarse en otra bóveda:
   `python3 "$CORE" transaction apply BUNDLE --vault VAULT --approved-plan-sha256 HASH`.
8. Informa el ID de la operación resultante y las rutas modificadas.
9. Si el usuario quiere historial de Git, ejecuta el comando de punto de control
   explícito, que es aparte.

## Forma del paquete

```json
{
  "schema": "claude-obsidian.transaction.v1",
  "operation_id": "save-20260711-example",
  "operation_type": "save",
  "expected_hashes": {
    "wiki/concepts/Example.md": null
  },
  "writes": [
    {
      "path": "wiki/concepts/Example.md",
      "mode": "create",
      "content_file": "drafts/example.md",
      "sha256": "<sha256>"
    }
  ],
  "address_requests": [],
  "source_manifest_updates": {}
}
```

`content` puede reemplazar a `content_file` en borradores pequeños. Usa
exactamente uno. Los contenidos de fuentes sin procesar son de solo creación. El
motor de transacciones expande y registra en el diario `.raw/.manifest.json` y el
contador de direcciones cuando hay solicitudes administradas. Solo `ingest` y
`autoresearch` son dueños de solicitudes administradas no vacías; `setup` y
`migration` pueden inicializar directamente los archivos administrados. Los
demás tipos de operación no pueden tenerlos como destino.

Los tipos de operación son autoridades que se hacen cumplir, no etiquetas:
`base` escribe solo `wiki/**/*.base`; `canvas` escribe canvas bajo
`wiki/canvases/` y su `_index.md` opcional; `fold` escribe exactamente una
página `wiki/folds/*.md` más `wiki/index.md` y `wiki/log.md`; `configuration`
escribe solo `.vault-meta/mode.json`; y `capture` crea solo contenidos
`.raw/captured/*`. Los paquetes de guardado, de Markdown, de reparación del lint
y de extensión genérica siguen confinados a `wiki/`. `setup` y `migration`
aceptan solo las rutas exactas versionadas de la plantilla de bóveda, de los
registros y del arranque de DragonScale que declara el contrato del producto; no
son vías de escape para archivos arbitrarios de la raíz, de plugins, de
fragmentos, de metadatos o de la wiki. Se rechazan las rutas que colisionan por
mayúsculas y minúsculas, por portabilidad con macOS.

Un archivo de contenido o de predecesor puede pesar como máximo 64 MiB, y el
contenido nuevo o las copias de seguridad de recuperación de una operación
pueden sumar como máximo 128 MiB. Divide el trabajo más grande en un límite
lógico antes de la inspección; el motor rechaza una operación que no podría
revertir bajo los mismos límites.

Una operación puede contener como máximo 1,024 escrituras. Cada ruta canónica
relativa a la bóveda puede usar como máximo 1,024 bytes UTF-8. Los paquetes de
transacción respaldados por archivo deben ser archivos regulares sin seguimiento
de enlaces y pueden pesar como máximo 136 MiB; los diarios y los
resultados completados se comprueban de antemano contra el mismo tope de 8 MiB
que usa la recuperación. Estos límites garantizan que toda operación aceptada
siga siendo legible y recuperable.

El bloqueo conserva los descriptores de directorio de la bóveda seleccionada y
de `.vault-meta` durante toda la operación. Los destinos, diarios, resultados,
copias de seguridad, colas de captura, puntos de control y publicaciones
derivadas de la búsqueda usan E/S basada en descriptores sin seguimiento de
enlaces, de modo que reemplazar una entrada pública de la raíz, de los
metadatos, de las transacciones, de las operaciones o de las copias de seguridad
no pueda redirigir lecturas, escrituras, reversiones ni limpiezas fuera de la
bóveda seleccionada. Este confinamiento requiere descriptores de directorio
POSIX y `fcntl.flock`; los usuarios de Windows deben ejecutar la skill bajo WSL
en lugar de Windows nativo o Git Bash (instalación y solución de problemas:
`docs/windows-wsl.md`).

## Escrituras acopladas obligatorias

- Guardado: nota, índice, bitácora, caché caliente.
- Ingesta: captura de la fuente cuando corresponda, páginas, registros de
  ingesta y de evidencia, índices o MOC, bitácora, caché caliente y vista
  general opcional.
- Autoresearch: páginas de investigación con citas y registros de evidencia. La
  fusión canónica es una transacción aparte y aprobada.
- Consolidación (fold): página de consolidación, índice, bitácora.
- Canvas: el canvas más los metadatos del catálogo solo cuando esos metadatos
  cambian.
- Reparación del lint: correcciones aprobadas más el informe o índice
  regenerado.
- Consulta: solo lectura. Delega la persistencia en el guardado.

## Comportamiento ante fallos

- El código de salida 75 significa que la bóveda cambió o que otra operación
  tiene el bloqueo de modificación. Vuelve a leer, reconstruye e inspecciona un
  paquete nuevo.
- Un fallo de validación significa que no se produjo ninguna escritura en la
  bóveda.
- Una aplicación interrumpida se recupera o se revierte con la siguiente
  aplicación, o con `transaction recover`.
- La recuperación nunca roba un bloqueo antiguo solo porque haya transcurrido su
  antigüedad. Después de confirmar de forma independiente que no hay ningún
  escritor activo, un operador puede usar
  `transaction recover --force-stale-lock`; existe la misma anulación explícita
  para `capture queue recover`. No automatices ninguna de las dos anulaciones.
- Nunca disimules un fallo de transacción con `|| true`.

## Punto de control explícito

```bash
python3 "$CORE" checkpoint OPERATION_ID --vault VAULT \
  --as-of YYYY-MM-DD
```

Crear un punto de control nunca es automático. Rechaza todo estado preexistente
en el área de preparación de Git, verifica los bytes de los blobs del árbol
candidato contra los hashes de la transacción, ejecuta el lint determinista por
defecto y excluye los contenidos de fuentes sin procesar salvo que el usuario lo
acepte de forma explícita. `--as-of` fija y registra la fecha UTC de la
auditoría de procedencia; una entrada pendiente reanuda el mismo commit y la
misma fecha fijada tras una interrupción.
