# Perfiles de estructura inicial específicos de un dominio

Inicializa o adopta primero la bóveda base. Un perfil agrega carpetas, tipos de
página y secciones del índice en una sola transacción inspeccionada; no
reemplaza la metodología organizativa seleccionada (`generic`, `lyt`, `para` o
`zettelkasten`). Conserva las notas y las rutas existentes.

Todo perfil mantiene estos invariantes:

- fuentes capturadas inmutables bajo `.raw/`;
- conocimiento generado bajo `wiki/`;
- `wiki/index.md`, `wiki/log.md` y `wiki/hot.md` como páginas canónicas del
  ciclo de vida;
- registros de evidencia y de afirmaciones bajo `wiki/meta/ledgers/`;
- una transacción a nivel de operación para una estructura inicial solicitada;
- ninguna configuración remota, de plugins, de salida de red ni de Git sin
  aprobación aparte.

## Sitio web o sistema de contenido

Rutas sugeridas: `wiki/pages/`, `wiki/structure/`, `wiki/audits/`,
`wiki/keywords/` y `wiki/entities/`.

Las propiedades de página útiles incluyen la URL de origen, el estado del ciclo
de vida, la URL canónica, la fecha de la última verificación y el número de
enlaces internos. Trata las exportaciones de rastreo y de analítica como
fuentes; no afirmes indexación en vivo ni estado HTTP sin evidencia actual.

## Repositorio de software

Rutas sugeridas: `wiki/modules/`, `wiki/components/`, `wiki/decisions/`,
`wiki/dependencies/` y `wiki/flows/`.

Registra rutas relativas al repositorio, propósito, estado, relaciones de
dependencia y evidencia procedente del código, las pruebas, los issues o la
documentación primaria. Las páginas de arquitectura generadas deben distinguir
el comportamiento observado de la inferencia.

## Negocio o proyecto

Rutas sugeridas: `wiki/stakeholders/`, `wiki/decisions/`,
`wiki/deliverables/`, `wiki/intel/` y `wiki/meetings/`.

Registra la fecha de la decisión, el responsable, el estado, la justificación y
la fuente registrada. Conserva los recuerdos contradictorios como evidencia
en disputa en lugar de reescribir la historia.

## Bóveda de conocimiento personal

Rutas sugeridas: `wiki/goals/`, `wiki/learning/`, `wiki/people/`,
`wiki/areas/` y `wiki/resources/`.

Usa por defecto el procesamiento solo local. Confirma la privacidad y la
retención antes de capturar mensajes, datos de salud, finanzas, relaciones o
voz. No guardes una conversación completa cuando el usuario pidió conservar solo
una idea.

## Investigación

Rutas sugeridas: `wiki/papers/`, `wiki/concepts/`, `wiki/entities/`,
`wiki/syntheses/` y `wiki/gaps/`.

Haz seguimiento en los registros del respaldo de las afirmaciones, las
contradicciones, la autoridad, la independencia, la vigencia y el riesgo. El
resumen de un artículo es secundario respecto del artículo capturado y no valida
automáticamente sus afirmaciones.

## Complemento de un libro o curso

Rutas sugeridas: `wiki/chapters/`, `wiki/concepts/`, `wiki/people/`,
`wiki/exercises/` y `wiki/reflections/`.

Captura solo el material que el usuario esté autorizado a almacenar. Prefiere
notas concisas enlazadas a la fuente en lugar de reproducir capítulos o
transcripciones con derechos de autor.

## Aplicar un perfil

1. Inspecciona la metodología actual y notas representativas.
2. Redacta un mapa de carpetas, páginas y propiedades e identifica los
   conflictos de nombres.
3. Muestra las rutas propuestas y cualquier adición al esquema.
4. Aplica las adiciones aprobadas una sola vez mediante el núcleo de
   transacciones.
5. Ejecuta el lint determinista e informa de los hallazgos sin resolver.
6. Deja que el uso real determine los refinamientos posteriores, en lugar de
   construir de antemano una jerarquía vacía.
