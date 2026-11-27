# Privacidad

claude-obsidian es local por defecto y no tiene telemetría ni analítica. El núcleo
portátil guarda el contenido de la bóveda en el sistema de archivos seleccionado y
no hace solicitudes de red. Esto no significa que todo host funcione sin conexión:
el agente de programación con IA, una herramienta web invocada o un adaptador
externo configurado pueden enviar contenido seleccionado a su proveedor bajo la
política propia de esa herramienta.

## Local por defecto

- Las páginas Markdown, los bytes de las fuentes sin procesar, los registros, las
  colas, los diarios de transacciones, los índices BM25 y la caché caliente
  permanecen por defecto en la bóveda del usuario.
- El hook SessionStart guarda silencio a menos que el usuario exporte
  explícitamente `CLAUDE_OBSIDIAN_SESSION_CONTEXT=1`. Con ese consentimiento, emite
  datos acotados y sanitizados de `wiki/hot.md` en el contexto de la sesión de
  Claude; nunca captura una transcripción. La configuración de un espacio de
  trabajo solo puede gastar ese consentimiento global en una bóveda dentro de su
  propio árbol de proyecto. Para una ruta intencional a una bóveda externa,
  define también `CLAUDE_OBSIDIAN_SESSION_CONTEXT_VAULT` con la ruta canónica
  exacta de esa bóveda; esto impide que una configuración de proyecto no
  confiable redirija la inyección automática de contexto a otra bóveda privada.
- El hook Stop emite solo el estado agregado de recuperación cuando se requiere
  una intervención; no incluye identificadores de operación, rutas ni contenido de
  notas.
- La captura desde el sistema de archivos copia los bytes direccionándolos por
  contenido y nunca elimina el origen visible en la bandeja de entrada.
- La compatibilidad con imágenes, PDF y EPUB es solo de metadatos en el núcleo.
  Las URL, YouTube, el OCR, la transcripción y la extracción semántica no se
  ejecutan en el núcleo.
- El lint, las simulaciones de migración, los planes de captura, las
  comprobaciones de contratos y las auditorías de artefactos son de solo lectura.

## Salida de red explícita

El acceso a la red requiere un flujo de trabajo intencional y consentimiento en el
límite de la operación:

- `autoresearch` y la limpieza de URL envían términos de búsqueda o URL a través
  de las herramientas web del host.
- La generación de prefijos contextuales puede enviar texto de páginas a un modelo
  configurado solo con su indicador explícito de salida de red; las alternativas
  locales y BM25 siguen disponibles.
- Los endpoints remotos de Ollama se rechazan a menos que se indique la
  aceptación explícita de lo remoto.
- Las acciones externas de captura son planes argv inertes. Un ejecutor
  configurado por separado debe revalidar las redirecciones HTTPS y las
  direcciones de red públicas antes de usarlas.

Nunca pongas credenciales en una nota de fuente, en la consulta de una URL, en una
configuración versionada, en un paquete de transacción ni en una cola de captura.
Las compilaciones de distribución también rechazan direcciones de correo
personales reconocibles; solo se aceptan dominios de ejemplo reservados e
identidades noreply generadas por GitHub. El análisis de la publicación es defensa
en profundidad, no un servicio de descubrimiento de secretos ni de identidad.
Consulta [SECURITY.md](SECURITY.md) para el informe privado.
