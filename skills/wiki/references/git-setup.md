# Historial de Git opcional

Git es opcional. La corrección de la bóveda proviene de las transacciones de
operaciones, los hashes esperados, los diarios de recuperación y la validación
determinista, no de commits en segundo plano.

## Inicializar solo con aprobación

No inicialices un repositorio, ni agregues un remoto, ni agregues archivos al
área de preparación (stage), ni hagas commit, ni hagas push solo porque se creó
la estructura inicial de una bóveda. Si el usuario pide un historial local,
primero muestra la bóveda seleccionada y la acción planeada, y luego inicializa
Git en esa bóveda. Mantén excluidos el estado del espacio de trabajo, las
cachés, los secretos y la papelera.

Una política típica de exclusión para la bóveda de un usuario incluye:

```gitignore
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.trash/
.DS_Store
.vault-meta/
```

Los paquetes de transacciones, los diarios de recuperación, las colas y los
fragmentos derivados pueden contener texto de notas, rutas locales o URLs de
fuentes, así que mantén todo `.vault-meta/` ignorado por defecto. Si el usuario
quiere versionar de forma deliberada un archivo de configuración estable de ese
directorio, agrega la excepción revisada más estrecha y deja ignorados los
subárboles de ejecución. Ajusta las demás entradas a los complementos y a las
necesidades de privacidad reales. No copies a ciegas el archivo de exclusión del
repositorio del producto.

`checkpoint` hace commit de exactamente una operación completada y, por eso,
requiere un commit padre existente. Después de `git init`, crea una base de
referencia revisada y aparte antes de ejecutar cualquier operación de la que
quieras un punto de control:

```bash
git status --short
git add -- <reviewed-baseline-paths>
git diff --cached --stat
git diff --cached
git commit -m "vault: reviewed baseline"
```

Elige las rutas de la base de referencia de forma deliberada; no agregues al
área de preparación (stage) estado de ejecución ignorado, secretos ni contenido
sin procesar solo para que el repositorio no esté vacío. El comando checkpoint
nunca crea esta base de referencia ni incorpora en silencio archivos
preexistentes en el commit de una operación.

## Puntos de control de una operación exacta

Tras una transacción exitosa de claude-obsidian, un punto de control pedido de
forma explícita es:

```bash
python3 "$CORE" checkpoint OPERATION_ID --vault "$VAULT"
```

El comando verifica los hashes registrados, rechaza cualquier estado
preexistente en el área de preparación de Git, ejecuta el lint determinista por
defecto y excluye el contenido sin procesar de las fuentes a menos que el
usuario elija incluirlo. Construye y verifica el commit mediante un índice
temporal y luego avanza la referencia mediante una operación de comparar e
intercambiar (compare-and-swap). Una anotación pendiente duradera permite
reintentar sin riesgo una finalización interrumpida. Revisa el commit devuelto
con `git show`. Hacer push o agregar un remoto es una acción externa aparte que
requiere autorización explícita del usuario.

Evita los complementos de commit automático durante las operaciones de agentes,
porque pueden capturar un estado parcial o ajeno e invalidar el historial de
operaciones exactas.
