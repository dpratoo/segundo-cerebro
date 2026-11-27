# Hooks de Claude Code

`hooks.json` es un adaptador delgado de Claude Code alrededor del núcleo portátil.

Los hooks requieren una versión actual de Claude Code: la forma ejecutable de los
hooks con `command` y `args` y los matchers `compact` y `fork` de `SessionStart`
que se usan más abajo la necesitan
(consulta el [contrato de hooks de Claude Code](https://code.claude.com/docs/en/hooks)).
Ambos hooks también necesitan un intérprete accesible como `python3` en `PATH`;
consulta la
[guía de Windows y WSL](../docs/windows-wsl.md#hooks-de-claude-code-y-python3-en-windows)
para la configuración en Windows nativo.

| Evento | Matcher | Comportamiento |
|---|---|---|
| `SessionStart` | `startup|resume|clear|compact|fork` | Silencioso por defecto. Con `CLAUDE_OBSIDIAN_SESSION_CONTEXT=1`, resuelve una bóveda real del usuario y emite un bloque de datos acotado y saneado de `wiki/hot.md`. Una bóveda configurada en el espacio de trabajo y ubicada fuera de ese proyecto también requiere una ruta exacta en `CLAUDE_OBSIDIAN_SESSION_CONTEXT_VAULT`. |
| `Stop` | no admitido / omitido | Emite un `systemMessage` JSON agregado y acotado cuando hace falta recuperación. Omite los identificadores de operación, las rutas y el contenido de las notas; en cualquier otro caso es silencioso. |

Ambos son hooks de tipo `command` que usan un ejecutable más un arreglo de
argumentos y `${CLAUDE_PLUGIN_ROOT}` solo para ubicar el código del plugin. No
usan la caché del plugin como bóveda.

Las formas de respuesta siguen el [contrato de hooks de Claude Code](https://code.claude.com/docs/en/hooks)
vigente: un SessionStart con adhesión voluntaria puede agregar contexto mediante
stdout, mientras que las advertencias de Stop usan el campo `systemMessage` de
nivel superior admitido. Stop no tiene matcher porque ese evento no admite uno.
Ambos lectores rechazan las rutas con enlaces simbólicos y limitan la cantidad de
elementos que analizan y los bytes de salida.

Los hooks nunca escriben conocimiento, actualizan `wiki/hot.md`, preparan
archivos (stage), hacen commits de Git, ejecutan llamadas remotas ni eluden la
aprobación de transacciones. Los mismos flujos de trabajo siguen siendo
utilizables en hosts que no admiten los hooks de Claude.
