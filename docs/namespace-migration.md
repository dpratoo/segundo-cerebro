# Espacio de nombres del plugin de Claude

> **Nota:** esta guía describe la migración de la versión 3.0.0 a la 3.0.1 del
> proyecto original (marketplace `agricidaniel-claude-obsidian`). Si instalaste
> desde `segundo-cerebro`, no tienes que hacer nada.

La identidad del plugin de Claude es `claude-obsidian`, así que sus comandos son
`/claude-obsidian:*`. El repositorio, el núcleo portátil de Python, la
configuración de la bóveda y los esquemas de transacciones usan el mismo nombre.
Las bóvedas de usuario nunca necesitan un cambio de nombre ni una migración de
contenido por un cambio en la identidad del plugin.

Solo la versión 3.0.0 distribuyó el plugin como `agricidaniel-obsidian`. La
versión 3.0.1 restaura `claude-obsidian`, el nombre que los usuarios han invocado
desde la primera publicación.

`claude plugin validate` informa como error un nombre de plugin que empieza por
`claude-`, porque el nombre parece el de un plugin propio de Anthropic, y
`claude plugin init` y `claude plugin tag` lo rechazan. Claude Code igualmente
instala y carga un plugin así. El propietario conservó el nombre publicado, así
que el error de nombre reservado del validador del host es una excepción
aprobada; el `package validate` del propio proyecto acepta `claude-obsidian` y
sigue rechazando cualquier otro nombre reservado. El directorio de plugins de
Anthropic no incluiría el plugin con este nombre. Consulta la
[referencia actual del manifiesto](https://code.claude.com/docs/en/plugins-reference#name).

## Probarlo desde una copia de trabajo

Carga una copia de trabajo local sin cambiar el plugin instalado:

```bash
claude --plugin-dir /absolute/path/to/claude-obsidian
```

Invoca `/claude-obsidian:wiki`, `/claude-obsidian:save` u otras skills con el
mismo prefijo. Si el mismo nombre está instalado desde el marketplace, desactiva
esa copia durante la sesión para que se cargue la copia de trabajo.

## Actualización publicada

El canal del marketplace es `agricidaniel-claude-obsidian`. Su entrada de plugin
es `claude-obsidian`, en coincidencia con el manifiesto, y el marketplace incluye
un mapa `renames` de nivel superior de `agricidaniel-obsidian` a
`claude-obsidian`, como describe el
[mecanismo de cambio de nombre documentado](https://code.claude.com/docs/en/plugins/host-marketplace#rename-or-remove-a-plugin).

**Desde 2.x.** El nombre del plugin nunca cambió para ti, así que es una
actualización normal:

```bash
claude plugin marketplace update agricidaniel-claude-obsidian
claude plugin update claude-obsidian@agricidaniel-claude-obsidian
```

Reinicia Claude Code. Los comandos siguen siendo `/claude-obsidian:*`.

**Desde 3.0.0.** Actualiza la copia del marketplace:

```bash
claude plugin marketplace update agricidaniel-claude-obsidian
```

Claude Code reescribe de vuelta a `claude-obsidian` la clave
`agricidaniel-obsidian@agricidaniel-claude-obsidian` en `enabledPlugins` y
`pluginConfigs`, en los ámbitos de usuario, proyecto y local, y luego desinstala
el plugin 3.0.0. Instala una vez el nombre restaurado y reinicia:

```bash
claude plugin install claude-obsidian@agricidaniel-claude-obsidian
```

Claude Code no puede reescribir la configuración administrada. Un administrador
que haya habilitado ahí `agricidaniel-obsidian@agricidaniel-claude-obsidian` debe
volver a cambiar la clave a `claude-obsidian@agricidaniel-claude-obsidian`.

Se elimina el mapa de 3.0.0 de `claude-obsidian` a `agricidaniel-obsidian`,
porque un nombre no puede ser a la vez el actual y el anterior.
`package validate` rechaza una cadena de cambios de nombre que no termine en un
plugin listado o en `null`, y el conjunto de pruebas exige que la identidad de
3.0.0 siga migrando a la actual.

### Verificar

Después de la actualización o la instalación, comprueba que la versión y la
fuente esperadas estén instaladas y habilitadas, y que ninguna entrada informe un
error:

```bash
claude plugin list --json
```

En una bóveda desechable, confirma que el espacio de nombres expone `wiki`,
`save`, `wiki-ingest` y `wiki-query` una sola vez; confirma la selección
explícita de la bóveda, una operación revisada de guardado o ingesta y una
consulta que deje la bóveda sin cambios. Un listado de plugins instalados o un
validador de metadatos por sí solos no establecen que las skills se carguen ni
que la operación tenga éxito.

### Revertir

Para volver a la última versión 2.x, reemplaza el canal por uno fijado a ella:

```bash
claude plugin marketplace remove agricidaniel-claude-obsidian
claude plugin marketplace add AgriciDaniel/claude-obsidian#v2.2.0
claude plugin install claude-obsidian@agricidaniel-claude-obsidian
claude plugin list --json
```

Quitar un marketplace también quita los plugins instalados desde él, así que
reinstala desde el canal fijado como se muestra. Para avanzar de nuevo, quita el
canal fijado, agrega `AgriciDaniel/claude-obsidian` sin una ref e instala
`claude-obsidian@agricidaniel-claude-obsidian`. Los archivos de la bóveda no
requieren reversión para un cambio que solo afecta al adaptador.

## Evidencia y límites

Con Claude Code 2.1.306 el 2026-10-21, un `CLAUDE_CONFIG_DIR` aislado y un
marketplace git servido por smart HTTP local que se movió entre los árboles
v2.2.0, 3.0.0 y 3.0.1:

- Desde 2.2.0, `marketplace update` y luego `plugin update` llevaron
  `claude-obsidian` de 2.2.0 a 3.0.1 con la clave habilitada sin cambios.
- Desde 3.0.0, `marketplace update` reescribió la clave habilitada a
  `claude-obsidian@agricidaniel-claude-obsidian` y desinstaló
  `agricidaniel-obsidian`; un solo `plugin install` instaló entonces 3.0.1,
  habilitado.
- En una sesión cargada con `--plugin-dir`, las 15 skills y los 3 agentes
  aparecieron listados bajo `claude-obsidian:`.
- `claude plugin validate` informó un error, el nombre reservado, para el plugin
  y para el marketplace.

Ejecuciones anteriores de 3.0.0 con Claude Code 2.1.302 y 2.1.304 establecieron
que un marketplace sin una entrada `renames` deja a las instalaciones existentes
informando `Plugin not found in marketplace`, y que la reversión fijada a `v2.2.0`
reinstala archivos idénticos a la etiqueta.

El canal 3.0.1 alojado en GitHub, los ámbitos de proyecto y local, la
configuración administrada y Windows no se probaron. Revisa la ayuda del host de
destino antes de usarlo. Los cambios locales en el código fuente no autorizan la
instalación, los commits, la publicación ni cambios en la cuenta. Consulta la
[guía de instalación y desinstalación](install-guide.md).
