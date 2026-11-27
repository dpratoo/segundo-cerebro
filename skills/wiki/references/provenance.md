# Evidencia y procedencia

Mantén separados el estado de la ingesta, la evidencia de las fuentes y la
valoración de las afirmaciones.

Resuelve la raíz del producto instalado a partir de la ubicación de la propia
skill que la invoca, no del directorio de trabajo de la bóveda del usuario:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"
test -f "$CORE"
```

## Registros

- `.raw/.manifest.json`: hashes de ingesta compatibles con versiones anteriores,
  páginas generadas, mapa de direcciones y último resultado de procesamiento.
- `wiki/meta/ledgers/source-ledger.json`: identidades estables de las fuentes,
  autoridad, SHA-256, obtención y vigencia, estado de revisión y páginas
  enlazadas.
- `wiki/meta/ledgers/claim-ledger.json`: afirmaciones falsables, ubicaciones en
  las notas, respaldo, contradicciones, confianza, riesgo y estado de revisión.

No cargues un solo registro con los tres trabajos.

## Reglas de las fuentes

- Usa SHA-256 para la identidad de las fuentes nuevas y para las comprobaciones
  de deltas.
- Los localizadores de archivo son relativos a la bóveda. Los localizadores
  remotos son URLs HTTPS absolutas.
- La autoridad de una fuente es una de `official`, `primary`, `secondary`,
  `community`, `synthetic` o `unknown`.
- El estado de revisión es `unreviewed`, `active`, `superseded` o `rejected`.
- Calcula la obsolescencia a partir de `refresh_due`; no guardes una segunda
  marca de obsolescencia.
- Las fuentes que comparten un `independence_key` no cuentan como corroboración
  independiente.
- Las fuentes que se resuelven al mismo origen de URL canónico no cuentan como
  independientes solo porque cambie la escritura IPv6, IDN, Unicode, de
  segmentos de punto, de puerto predeterminado o de codificación porcentual. Los
  bytes reservados escapados de la ruta o de la consulta siguen siendo
  distintos, porque pueden identificar un recurso diferente.

## Reglas de afirmaciones

- La valoración es `accepted`, `provisional`, `contested`, `unsupported` o
  `deprecated`.
- Las afirmaciones aceptadas necesitan al menos una fuente vigente, activa y no
  sintética.
- Las afirmaciones aceptadas de alto riesgo necesitan dos fuentes
  independientes.
- Conserva la evidencia contradictoria. No elijas un ganador en silencio.
- `unsupported` es el estado canónico de ausencia de datos. Una negativa
  fundamentada es mejor que una invención segura de sí misma.
- Nunca inventes citas textuales, números de página, fechas ni localizadores de
  evidencia.

## Migración

Ejecuta la migración primero como simulación:

```bash
python3 "$CORE" migrate --vault VAULT \
  --generated-at <ISO-UTC> --operation-id migrate-reviewed
python3 "$CORE" migrate --vault VAULT \
  --generated-at <ISO-UTC> --operation-id migrate-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

La migración deja `.raw/.manifest.json` idéntico byte a byte, crea los registros
que faltan, asigna valores predeterminados honestos a los campos de evidencia
desconocidos y nunca extrae afirmaciones de la prosa heredada de forma
automática. Una clave de fuente heredada que se resuelve a un archivo regular
sigue siendo una fuente de archivo con su SHA-256 calculado. Una clave válida
sin archivo se conserva como una fuente manual sin revisar, con autoridad
desconocida y sin hash de contenido verificado. Esta entrada sin resolver
conserva la identidad heredada, la fecha y los enlaces de página; no demuestra
una relación entre lote y archivo. La migración nunca enumera los contenidos sin
procesar para inventar esa relación ni promueve el hash corto heredado a
SHA-256.
El paquete de migración revisado también fija el estado observado del archivo de
cada localizador heredado. La aplicación falla si aparece una etiqueta sin
resolver, si pasa a ser no segura, si no se puede inspeccionar o si una fuente
de archivo cambia después de la revisión.
