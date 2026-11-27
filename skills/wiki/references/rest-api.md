# Contrato de seguridad del adaptador REST

Local REST API es un complemento opcional de Obsidian de terceros.
claude-obsidian no lo instala, no lo requiere ni lo usa como transporte de
modificaciones.

## Antes de usarlo

- Confirma que el usuario instaló y habilitó el complemento de forma
  intencional.
- Lee la documentación primaria vigente del complemento y verifica la versión
  exacta de la API y sus endpoints en lugar de confiar en ejemplos recordados.
- Mantén el servidor escuchando en loopback por defecto y guarda su credencial
  en un entorno protegido o en un gestor de secretos.
- Nunca imprimas la credencial, ni la incrustes en una nota, ni la incluyas en
  un commit, ni la pongas en una transcripción de comandos reutilizable.
- Exige la verificación TLS normal. No uses `curl -k`,
  `NODE_TLS_REJECT_UNAUTHORIZED=0` ni otra omisión que afecte a todo el proceso.

## Función permitida

Usa un adaptador REST configurado solo para las operaciones de lectura y de
búsqueda que el usuario haya incluido en el alcance. Valida las rutas devueltas
y rechaza el recorrido de directorios y los escapes mediante enlaces simbólicos.
Una respuesta HTTP exitosa demuestra el comportamiento del transporte, no la
veracidad del contenido devuelto.

Las solicitudes de crear, reemplazar, anexar, aplicar parches, mover y eliminar
quedan fuera del contrato de este adaptador. Expresa cada cambio de la bóveda
como una sola operación `claude-obsidian.transaction.v1` inspeccionada, de modo
que los hashes esperados, la procedencia, el diario y la recuperación sigan
aplicándose.

Si no se puede configurar TLS seguro o acceso con privilegios mínimos, usa en su
lugar lecturas directas del sistema de archivos o la superficie de lectura de la
CLI oficial verificada.
