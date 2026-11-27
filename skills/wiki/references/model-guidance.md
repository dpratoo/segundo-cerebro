# Compatibilidad con modelos y hosts

Las skills canónicas describen resultados, evidencia y límites de modificación.
Deja que el host elija su modelo; no incluyas de forma fija el nombre de un
modelo ni frontmatter exclusivo de un host en los flujos de trabajo portátiles.
Mantén privado el razonamiento privado e informa la respuesta, la evidencia que
la respalda, las acciones y los límites sin resolver.

Para Opus 5.5, inicia una evaluación controlada con su esfuerzo `medium` por
defecto y mide la calidad, la latencia y el uso antes de cambiarlo. Su
razonamiento siempre es adaptativo. Los adaptadores de API deben leer los
bloques de contenido por tipo, manejar el rechazo y la salida incompleta, y
evitar la elección forzada de herramientas. Los prompts claros que ya existen
no necesitan una reescritura total solo porque cambió el modelo.

Al construir un prompt a partir de texto de origen, usa un delimitador nuevo
generado por la aplicación, codifica de forma segura los campos de origen e
indica que el texto delimitado son datos no confiables. Un delimitador es
defensa en profundidad, no una prueba de resistencia a la inyección. Valida los
artefactos generados de forma independiente antes de usarlos.

Guía principal, revisada el 2026-10-17:

- [Prompts para Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)
- [Migración a Opus 5.5](https://platform.claude.com/docs/en/models/opus-5-5/migration-guide)

Para una ejecución de aceptación, registra las versiones exactas del modelo y del
host, los hashes de las skills, los hashes de los fixtures, las opciones
efectivas, los permisos de las herramientas y el uso. Usa fuentes sintéticas en
una bóveda desechable y compara condiciones emparejadas sobre los mismos casos.
Mantén separadas la evidencia sin conexión, la del modelo, la de carga en el
host y la nativa de Obsidian. Nunca deduzcas de una prueba local el permiso para
enviar una bóveda privada a un proveedor.
