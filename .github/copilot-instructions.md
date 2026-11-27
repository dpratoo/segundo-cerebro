# Instrucciones de Copilot para claude-obsidian

Lee `AGENTS.md` antes de proponer cambios. El repositorio es un paquete de Agent
Skills, un adaptador de Claude Code, un núcleo de Python de biblioteca estándar y
una plantilla de bóveda determinista, no la bóveda de usuario activa por defecto.

Al editar:

- Mantén el frontmatter de las skills en exactamente `name` y un `description` de
  una sola línea.
- Usa Obsidian Flavored Markdown, propiedades YAML planas y fechas `YYYY-MM-DD`.
- Nunca modifiques el contenido sin procesar existente de las fuentes.
- Encauza todas las modificaciones lógicas de conocimiento por un único paquete de
  operación inspeccionado.
- Mantén a los agentes limitados a redactar borradores y el lint y las consultas
  en solo lectura.
- Conserva la contención de las rutas de la bóveda y la separación entre producto
  y bóveda.
- Agrega pruebas de regresión herméticas para los cambios de comportamiento y
  ejecuta `make test`.
- No agregues secretos, rutas privadas, afirmaciones de capacidad sin respaldo ni
  contenedores de comandos duplicados.

Repositorio canónico público: https://github.com/dpratoo/segundo-cerebro
