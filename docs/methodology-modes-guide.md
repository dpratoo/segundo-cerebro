# Modos de metodología

El modo de metodología es una preferencia de enrutamiento local de la bóveda para
las notas nuevas. No cambia las reglas de evidencia, la seguridad de las
transacciones ni los archivos existentes.

## Modos

| Modo | Principio | Rutas típicas |
|---|---|---|
| Genérico | Carpetas habituales por tipo, sin una metodología con nombre | `wiki/sources/`, `entities/`, `concepts/`, `sessions/` |
| LYT | Los mapas de contenido conectan notas atómicas | `wiki/mocs/`, `wiki/notes/` |
| PARA | Organiza según la capacidad de acción actual | `wiki/projects/`, `areas/`, `resources/`, `archives/` |
| Zettelkasten | IDs estables, notas atómicas, enlaces densos | Estructura plana `wiki/<id>-<slug>.md` |

Sin configuración, el modo es Genérico. Elige según tus hábitos de búsqueda y de
mantenimiento, no según el prestigio:

- Usa Genérico cuando los tipos bastan y el costo de migración debería seguir
  siendo bajo.
- Usa LYT cuando los mapas curados son la superficie principal de navegación.
- Usa PARA cuando el estado del proyecto o de la acción debería controlar la
  organización.
- Usa Zettelkasten cuando la atomicidad y los enlaces densos se practican de
  forma consistente.

## Leer el modo actual

```bash
python3 scripts/claude-obsidian.py mode get --vault <vault>
```

El enrutador de compatibilidad puede mostrar una vista previa de un destino sin
escribir:

```bash
python3 scripts/wiki-mode.py --vault <vault> route concept "Example concept" --mode lyt
```

Trata la salida del enrutador como una propuesta. Valídala como una ruta
relativa a la bóveda e incluye la ruta elegida en la vista previa de la
operación.

## Configurar con seguridad

Los cambios de modo usan una sola transacción de configuración y por defecto son
una simulación:

```bash
python3 scripts/claude-obsidian.py mode set para --vault <vault> \
  --generated-at <ISO-UTC> --operation-id mode-reviewed
python3 scripts/claude-obsidian.py mode set para --vault <vault> \
  --generated-at <ISO-UTC> --operation-id mode-reviewed \
  --approved-plan-sha256 <reviewed-sha256> --apply
```

El script de compatibilidad se comporta igual:

```bash
bash scripts/setup-mode.sh --vault <vault> --mode para
bash scripts/setup-mode.sh --vault <vault> --mode para \
  --generated-at <ISO-UTC> --approved-plan-sha256 <reviewed-sha256> --apply
```

Se conservan los ajustes de ruta personalizados existentes. El comando no crea
carpetas, no mueve notas, no reescribe enlaces ni migra contenido antiguo.

El asignador de Zettelkasten tiene un único formato canónico:
`YYYYMMDDHHMMSSffffff-UUID4HEX`. Un `id_format` heredado que solo contiene la
marca de tiempo se normaliza en la salida de lectura y en la siguiente
transacción `mode set` revisada; los nombres de archivo existentes no se
renombran. Los componentes del nombre de archivo enrutado están acotados a 255
bytes UTF-8, con un sufijo de hash determinista cuando hay que acortar un
título.

## Cambiar de modo

El cambio solo afecta al enrutamiento posterior. Antes de cambiar:

1. identifica qué flujos de trabajo consumen rutas;
2. obtén una vista previa de nombres representativos de fuentes, entidades,
   conceptos, sesiones e investigación;
3. revisa si hay colisiones de nombres de archivo o de nombres base;
4. aplica la transacción de configuración;
5. ejecuta el lint determinista después de la primera operación en el nuevo
   modo.

La reorganización masiva es un proyecto de migración aparte. Necesita un mapa
completo de movimientos, un plan de reescritura de enlaces, hashes esperados,
manejo de colisiones, reversión y aprobación explícita del usuario. Nunca la
conviertas en un efecto secundario de `mode set`.

## Cómo usan el modo las skills

`wiki-ingest`, `save` y `autoresearch` pueden llamar al enrutador mientras
redactan. Los agentes incluyen la ruta propuesta en su paquete de borrador; el
orquestador padre decide y aplica la ruta final. La consulta, el lint y la
búsqueda no cambian su comportamiento según el modo de metodología.

El modo es un metadato de organización, no evidencia. La carpeta de una nota no
aumenta su autoridad, su vigencia ni su confianza.

## Solución de problemas

| Síntoma | Respuesta |
|---|---|
| Falta la configuración | Genérico está activo; no hay nada roto. |
| JSON no válido | Repáralo o reemplázalo mediante una transacción revisada; el enrutador falla de forma segura. |
| Ruta inesperada | Genera una vista previa con un `--mode` explícito, inspecciona los ajustes personalizados y sanea el nombre. |
| Estructura antigua y nueva mezclada | Es lo esperado tras cambiar de modo; no muevas automáticamente las notas más antiguas. |
| Duda sobre los IDs de Zettelkasten | Los IDs nuevos combinan un prefijo UTC ordenable con microsegundos y un nonce UUIDv4. Los IDs existentes que solo contienen la marca de tiempo siguen siendo válidos; aun así, detecta las colisiones de destino antes de aplicar. |
