---
name: wiki-cli
description: "Detecta y usa la interfaz de línea de comandos oficial de Obsidian para acceder a la bóveda en solo lectura. Toda modificación pasa por el núcleo de transacciones de claude-obsidian. Se activa con: wiki-cli, Obsidian CLI, lee con Obsidian, busca con Obsidian, transporte de la bóveda, qué transporte se usa, detecta el transporte, enlaces entrantes, etiquetas, línea de comandos de Obsidian."
---

# Transporte de lectura de Obsidian CLI

Usa esta skill solo para detectar el transporte y para leer o buscar en una
bóveda seleccionada. El ejecutable oficial es `obsidian`; la sola presencia del
binario no demuestra que se pueda usar.

Resuelve la raíz del producto instalado a partir de la ubicación de esta skill,
no de la bóveda ni del directorio de trabajo actual:

```bash
PRODUCT_ROOT=/absolute/path/to/installed/claude-obsidian
DETECT_TRANSPORT="$PRODUCT_ROOT/scripts/detect-transport.sh"
test -f "$DETECT_TRANSPORT"
```

Cada enlace `../wiki/references/` de este archivo se resuelve de la misma
forma: respecto del directorio propio de esta skill dentro de `$PRODUCT_ROOT`,
nunca respecto del directorio `wiki/` de la bóveda seleccionada.

## Detectar de forma segura

Sondea sin persistir el estado del host:

```bash
bash "$DETECT_TRANSPORT" --peek --vault "$VAULT"
```

Confía en `available.cli.usable`, no solo en `present` ni en el estado de
salida. Una CLI compatible puede seguir sin estar disponible porque la
aplicación de Obsidian no está en ejecución, porque el acceso por línea de
comandos está desactivado o porque su respuesta es un error. Usa lecturas del
sistema de archivos como alternativa portátil.

Guarda un `.vault-meta/transport.json` actualizado solo cuando el usuario o el
flujo de configuración pidan una instantánea del transporte:

```bash
bash "$DETECT_TRANSPORT" --force --vault "$VAULT"
```

Ese archivo es configuración de ejecución derivada, no contenido de
conocimiento. Conserva un `manual_override` válido registrado por el detector.

## Leer y buscar

Ejecuta los comandos oficiales de la CLI desde la bóveda seleccionada para que
Obsidian resuelva el espacio de trabajo correcto. Confirma la sintaxis admitida
con la CLI instalada antes de depender de comandos opcionales. Las formas
típicas de solo lectura son:

```bash
(cd "$VAULT" && obsidian read path="$NOTE")
(cd "$VAULT" && obsidian search query="$QUERY")
```

Usa comandos de solo lectura para enlaces entrantes, etiquetas o resultados de
Bases solo cuando el detector informe que la CLI está lista. De lo contrario,
lee los archivos bajo `$VAULT` directamente y usa `rg` para buscar. Rechaza
argumentos de nota absolutos, recorridos de rutas, enlaces simbólicos o rutas resueltas
fuera de la bóveda seleccionada.

## Límite de las modificaciones

No uses los comandos de la CLI para crear, escribir, anexar, definir
propiedades, anexar a la nota diaria, mover, renombrar o eliminar. No sustituyas
esos comandos por escrituras directas en el sistema de archivos. Todo cambio de
conocimiento o de configuración debe expresarse como una sola transacción
revisada a través del núcleo portátil; consulta las
[transacciones de operaciones](../wiki/references/operation-transactions.md).

La elección del transporte nunca cambia la semántica de las modificaciones. La
CLI es una superficie de lectura opcional, no un administrador de bloqueos, un
motor de transacciones ni un mecanismo de puntos de control de Git.

## Punto de control

Observa la capacidad real, piensa en el transporte de lectura menos complejo,
verifica que cada ruta resuelta permanezca dentro de la bóveda y acepta la
alternativa del sistema de archivos cuando la CLI no esté lista.
