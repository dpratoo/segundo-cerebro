# Capacidad y recuperación

Inspecciona la bóveda seleccionada antes de una operación grande:

```bash
python3 "$CORE" capacity --vault "$VAULT"
```

Esto lee el estado sin modificar la bóveda. Mantén por separado los bytes de los
registros, los bytes del archivo sin procesar, la cantidad de páginas y la cantidad de
fragmentos de búsqueda al medir la capacidad. De un fixture pequeño que pasa no
se deriva ninguna promesa sobre la cantidad de páginas ni una latencia
constante. Mide el rendimiento de copias representativas pequeñas, medianas y
grandes en el equipo de destino; conserva el tiempo transcurrido, la memoria, el
tamaño del índice, el resultado de la cancelación y el tiempo de recuperación.

Los registros canónicos de fuentes y de afirmaciones deben caber en el límite de
16 MiB del lector y del escritor. Las transacciones los verifican de antemano y
rechazan el crecimiento con `LEDGER_CAPACITY_EXCEEDED`. No elimines evidencia,
no reduzcas la fidelidad ni desactives la validación para quedar por debajo del
límite. Un registro heredado con mucho formato puede compactarse sin pérdida:

```bash
python3 "$CORE" capacity compact --vault "$VAULT" \
  --operation-id capacity-reviewed
# Define APPROVAL_SHA256 con el approved_plan_sha256 revisado.
python3 "$CORE" capacity compact --vault "$VAULT" \
  --operation-id capacity-reviewed \
  --approved-plan-sha256 "$APPROVAL_SHA256" --apply
```

Conserva una copia de seguridad completa y recuperable de la bóveda antes de
reparar. Revisa las rutas y los hashes de la operación. Esta reparación lee
entradas heredadas solo hasta 64 MiB y cambia el formato del JSON, conservando
cada entrada y la identidad de cada fuente. Reescribe solo los registros que
`capacity` informa como `near_capacity` (al menos el 85% del límite) o
`over_capacity`; los registros más pequeños quedan idénticos byte por byte, y
una bóveda sin ninguno es un `noop`. Si la representación canónica compacta
aún supera 16 MiB, falla con `LEDGER_MIGRATION_REQUIRED` y se niega de entrada
cuando ni siquiera quitar todo el espacio en blanco permitiría que cupiera.
Detente y conserva los datos; el particionado automático y la expulsión de
entradas no están implementados. Un aumento de tamaño arbitrario necesitaría
evidencia conjunta del lector, del escritor, del diario, de la memoria y de la
reversión.

La compactación es una transacción ordinaria, así que la inspección ejecuta la
misma validación semántica de procedencia que cualquier escritura de un
registro. Si la bóveda se desvió por una vía externa, por ejemplo una fuente de
`.raw/` editada después de la ingesta, de modo que su `content_sha256`
registrado ya no coincide, la inspección rechaza el plan con
`INVALID_PROVENANCE_LEDGER` aunque solo cambiaría el formato. No omitas la
validación. Recupera mediante una transacción normal y revisada que escriba un
registro corregido en forma compacta (una línea JSON sin espacios en blanco
prescindibles), con el hash esperado del registro actual y un plan aprobado.

Los escritores determinan cuánto duran los ahorros. `migration_bundle`
(`migrate`) ahora escribe los registros canónicos en esa forma compacta. El
planificador de `init`/`adopt` en `claude_obsidian/vault_ops.py` y los paquetes
escritos a mano aún pueden escribir JSON con sangría; eso es válido, y la
compactación solo pasa a ser relevante cuando uno de esos registros se acerca
al límite.

Un archivo de contenido o predecesor está acotado a 64 MiB; el contenido nuevo
de una operación o sus copias de seguridad de recuperación, a 128 MiB; las
escrituras, a 1,024. Estos techos de almacenamiento son distintos de los
límites más estrictos de los registros y de la capacidad operativa práctica.
Divide el trabajo grande en un límite lógico e inspecciona cada operación
acotada. Nunca dividas un único flujo de trabajo acoplado en aplicaciones por
archivo sin revisar.

Para una operación interrumpida, detén los escritores que compiten y conserva
la bóveda seleccionada con sus diarios y copias de seguridad de `.vault-meta/`.
Luego usa:

```bash
python3 "$CORE" transaction recover --vault "$VAULT"
```

La recuperación puede revertir una aplicación incompleta. No borres los diarios
para ocultar un error ni sobrescribas a mano archivos modificados. El código de
salida 75 exige una lectura y un plan nuevos. Si un destino de reemplazo existente se
eliminó después de una aplicación interrumpida, la recuperación lo deja ausente,
conserva el diario como `rollback-failed` y devuelve `ROLLBACK_FAILED`. Revisa
la eliminación externa y la copia de seguridad conservada antes de autorizar una
restauración aparte; la recuperación no lo recrea en silencio. Usa
`--force-stale-lock` solo después de establecer de forma independiente que no
hay ningún escritor activo. La cola de captura tiene una interfaz de
recuperación explícita aparte; no es una forma de eludir el bloqueo de
transacción. Consulta [coordination.md](../skills/wiki/references/coordination.md)
para las ediciones externas y los límites de varias máquinas.
