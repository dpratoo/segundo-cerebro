# Programa de investigación por defecto

Este es el programa acotado por defecto de `autoresearch`. Los límites que
proporcione el usuario pueden hacerlo más estricto. Los contratos de privacidad, de
procedencia y de transacciones de la skill siempre prevalecen sobre la guía
específica de un dominio.

## Objetivos

- Responder una pregunta de investigación precisa en lugar de recopilar un tema de
  forma indiscriminada.
- Preferir las fuentes primarias y oficiales y, después, el análisis
  independiente de alta calidad.
- Extraer afirmaciones falsables, entidades, conceptos, mecanismos y decisiones.
- Buscar contraevidencia, contradicciones, dependencias entre fuentes y vacíos
  abiertos.
- Separar las declaraciones directas de la fuente de la inferencia y de las
  recomendaciones.
- Detenerse cuando las fuentes adicionales repitan evidencia ya conocida o no
  puedan cambiar la respuesta.

## Presupuesto por defecto

- Rondas de búsqueda: como máximo 3
- Fuentes obtenidas por ronda: como máximo 5
- Páginas redactadas: como máximo 15
- Agentes en paralelo: como máximo la concurrencia segura disponible en el host

Antes de la salida de red, acuerda también los límites de tiempo transcurrido, de
costo, de dominios y de privacidad. Informa el uso del presupuesto después de cada
ronda. Alcanzar un objetivo de páginas no es motivo para inventar contenido;
registra las preguntas omitidas y detente.

## Evaluación de la evidencia

Usa los registros de fuentes y de afirmaciones, no solo una etiqueta de confianza
en prosa.

- `accepted`: respaldada por al menos una fuente vigente, activa y no sintética.
- Afirmaciones aceptadas de alto riesgo: respaldadas por dos fuentes
  independientes.
- `provisional`: útil, pero con respaldo incompleto.
- `contested`: la evidencia creíble no coincide.
- `unsupported`: sin evidencia adecuada.
- `deprecated`: reemplazada y conservada por su valor histórico.

La vigencia depende del dominio y de la afirmación. Registra las fechas de
publicación, de obtención y de revisión cuando se conozcan, establece un
`refresh_due` adecuado y nunca apliques un límite de antigüedad universal al
trabajo fundacional.

## Estilo de la salida

- Usa un lenguaje directo sin perder la incertidumbre necesaria.
- Cita cada afirmación relevante y no obvia con un registro de fuente y un
  localizador.
- Usa páginas cortas y enfocadas; divide por concepto cuando eso mejore la
  búsqueda.
- Indica `unknown`, `unsupported` o `contested` en lugar de llenar los vacíos.
- Conserva las citas textuales tal cual y mantenlas breves; en los demás
  casos, parafrasea.
- Nunca fabriques autores, fechas, URL, números de página, mediciones ni citas.

## Selección de fuentes

La autoridad depende de la pregunta:

- Software y productos: documentación oficial vigente, repositorios de código,
  especificaciones y pruebas reproducibles.
- Investigación académica: artículos originales, conjuntos de datos, métodos,
  correcciones y, cuando corresponda, revisiones sistemáticas.
- Negocios y mercados: presentaciones regulatorias, divulgaciones oficiales,
  conjuntos de datos primarios y reportajes independientes; indica cuándo un
  material es promocional.
- Temas médicos, legales y financieros: orientación autorizada vigente y
  evidencia primaria, con jurisdicción, población y limitaciones explícitas.

Las publicaciones de comunidades y las redes sociales pueden identificar
experiencias o pistas, pero no se convierten automáticamente en evidencia de alta
autoridad. Elimina duplicados entre fuentes sindicadas y registra una
`independence_key` compartida cuando los informes dependan del mismo origen.

## Condiciones de parada

Detente e informa el límite cuando ocurra cualquiera de estos casos:

- la pregunta acordada está respaldada de forma adecuada;
- se agotó un presupuesto;
- el usuario detiene o acota el trabajo;
- los resultados restantes repiten evidencia dependiente;
- la salida de red excedería los dominios aprobados o expondría contexto privado;
- no se puede verificar una afirmación clave;
- las fuentes requieren un acceso o unos derechos que el usuario no ha
  proporcionado.

El resultado de la investigación sigue siendo un dosier revisable. Fusionarlo en
las páginas canónicas es una transacción aprobada por separado.
