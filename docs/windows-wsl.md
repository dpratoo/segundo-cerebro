# Guía de Windows y WSL

claude-obsidian admite Windows nativo como plataforma de solo lectura y WSL como
la plataforma con todas las capacidades. Esta guía explica qué funciona en cada
una, por qué existe ese límite y cómo destrabar WSL cuando falla.

## Plataformas compatibles

| Capacidad | WSL / Linux / macOS | Windows nativo (incl. Git Bash) |
|---|---|---|
| Inspección, vistas previas de simulación, búsqueda | Sí | Sí |
| Escrituras en la bóveda (`transaction apply`, `init`, `adopt`, `migrate`, `capture apply`, `mode set`) | Sí | No: se rechazan con `UNSUPPORTED_PLATFORM` |
| Comandos de la cola de captura (incluido `capture queue list`, de solo lectura) | Sí | No: por ahora se rechazan; seguimiento en el [#151 del proyecto original](https://github.com/AgriciDaniel/claude-obsidian/issues/151) |
| Puntos de control de Git (`checkpoint`) | Solo Linux y macOS | No |
| Scripts de configuración en Bash y suites de pruebas de shell | Sí | No (solo POSIX) |
| Hooks de Claude Code (`SessionStart`, `Stop`) | Sí (funcionan sin configuración adicional) | Parcial: requiere `python3` en `PATH`; consulta [más abajo](#hooks-de-claude-code-y-python3-en-windows) |

Las bóvedas deben estar en un sistema de archivos con identidad de archivo
estable: NTFS sirve, pero los volúmenes FAT/exFAT (típicos de las memorias USB)
y algunos recursos de red compartidos se rechazan con `UNSAFE_VAULT_IDENTITY`:
mueve la bóveda a NTFS o trabaja dentro de WSL.

## Hooks de Claude Code y python3 en Windows

`hooks/hooks.json` lanza cada hook con el [hook de comando en forma ejecutable
de Claude Code](https://code.claude.com/docs/en/hooks): `"command": "python3"`
con un arreglo `args`. Claude Code resuelve `python3` como un ejecutable en
`PATH` y lo lanza directamente; no hay shell, así que no se consulta ningún
intermediario (shim) `.bat`, función de alias ni perfil del shell.

WSL y la mayoría de las instalaciones de Python en Linux y macOS proporcionan un
`python3` en `PATH` por defecto, así que los hooks funcionan ahí sin
configuración adicional. En Windows nativo, lo habitual es que no:

- Instalador de python.org: instala `python.exe`, no `python3.exe`. Agrega un
  intermediario (shim) `python3.exe` antes del intérprete en `PATH`, instala una
  distribución que incluya `python3.exe` o ejecuta Claude Code desde WSL para que
  los hooks resuelvan el `python3` de WSL.
- Python de Microsoft Store: el alias de ejecución de aplicación `python3` puede
  ser un sustituto que abre la Store en lugar de ejecutar Python. Desactiva el
  alias de ejecución de aplicación `python3` en la Configuración de Windows, luego
  instala Python desde python.org o WSL y confirma que el intérprete real esté en
  `PATH`.

Cuando no se puede resolver `python3`, Claude Code no logra lanzar el proceso del
hook, así que el código propio de claude-obsidian nunca se ejecuta y no puede
emitir un diagnóstico. En ese caso faltan en silencio tanto el contexto de
SessionStart como las advertencias de recuperación de Stop; el resto de
claude-obsidian (las skills y la CLI) no se ve afectado, porque solo la ruta
opcional de los hooks depende de `python3`.

## Por qué las escrituras requieren WSL

La seguridad de las modificaciones se basa en descriptores de directorio POSIX:
la raíz de la bóveda y cada directorio de ejecución permanecen fijados durante
toda la escritura, de modo que un enlace simbólico intercambiado o una carpeta
reemplazada de forma concurrente falla en modo cerrado en lugar de redirigir la
escritura (consulta la [guía de la bóveda compuesta](compound-vault-guide.md)).
Windows nativo no puede ofrecer esas primitivas, así que las escrituras se
rechazan de entrada en lugar de ejecutarse en silencio con garantías más débiles.

Se está considerando un modo degradado de escritura en Windows nativo (apagado
por defecto, detrás de una opción explícita de garantías reducidas) en el
[#151 del proyecto original](https://github.com/AgriciDaniel/claude-obsidian/issues/151).
Si WSL es un obstáculo para ti, ese issue es el lugar para opinar.

## Solución de problemas de WSL

Que WSL esté "instalado" no siempre significa que funcione. Síntomas y
comprobaciones, aproximadamente en el orden en que conviene probarlos:

| Síntoma | Qué revisar |
|---|---|
| `wsl --install` terminó, pero `wsl --status` o `wsl -l -v` se cuelgan indefinidamente | Este cuelgue, reportado en uso real, no tiene una causa confirmada. Sigue el flujo de diagnóstico y reporte de cuelgues de WSL de Microsoft que aparece abajo. |
| `wsl` informa un error de kernel o de versión | Ejecuta `wsl --update`, luego `wsl --shutdown` y vuelve a intentarlo. |
| WSL funcionaba antes y dejó de hacerlo tras una actualización o un cambio de software | No supongas una causa. Actualiza Windows y WSL, y luego sigue el flujo de solución de problemas de WSL de Microsoft. |
| El hash de aprobación de una simulación nativa falla dentro de WSL con `PLAN_CHANGED` | Es intencional: el hash de aprobación vincula la identidad del sistema de archivos del entorno que revisa. Haz la revisión de la simulación dentro de WSL cuando el plan se vaya a aplicar ahí; un `approved_plan_sha256` generado de forma nativa no se puede reutilizar desde WSL. |
| Las escrituras fallan con `UNSAFE_VAULT_IDENTITY` y mencionan la identidad de archivo estable | La bóveda está en FAT/exFAT o en un recurso de red compartido no admitido. Muévela a NTFS o mantenla dentro del sistema de archivos de WSL. |

Lista de comprobación para solucionar problemas de WSL:

1. Empieza con la
   [guía oficial de solución de problemas de WSL](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting)
   de Microsoft.
2. Confirma que la virtualización esté habilitada en BIOS/UEFI y que estén
   habilitadas tanto "Plataforma de máquina virtual" como "Subsistema de Windows
   para Linux". Reinicia después de habilitar cualquiera de las dos funciones.
3. Ejecuta `wsl --update` desde un símbolo del sistema con privilegios elevados,
   luego `wsl --shutdown`, y vuelve a intentar `wsl --status`.
4. Confirma que la configuración de inicio del hipervisor esté habilitada. Si hay
   un hipervisor de terceros instalado, usa una versión actual que sea
   compatible con Hyper-V o desactívalo temporalmente mientras diagnosticas el
   conflicto.
5. Si WSL sigue colgándose, sigue los
   [pasos de Microsoft para recopilar datos de cuelgues de WSL](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting-guide#wsl-hangs)
   y presenta el reporte resultante al proyecto WSL. No atribuyas el cuelgue a
   una causa específica sin diagnósticos que lo respalden.

## Trabajar entre Windows y WSL

El flujo de trabajo admitido en Windows nativo es: inspeccionar y revisar de
forma nativa, modificar dentro de WSL. Como los hashes de aprobación se vinculan
al entorno que los produjo, haz la simulación revisada en el mismo entorno en el
que se aplicará el plan. Mantener la bóveda dentro del sistema de archivos de WSL
(en lugar de en una unidad de Windows montada) evita tanto las salvedades de
identidad mencionadas arriba como la sobrecarga de rendimiento al cruzar el
límite entre ambos entornos.
