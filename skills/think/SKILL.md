---
name: think
description: "Aplica el ciclo de 10 etapas derivado de Fable (OBSERVAR, OBSERVAR, ESCUCHAR, PENSAR, CONECTAR, CONECTAR, SENTIR, ACEPTAR, CREAR, CRECER) a razonamientos y decisiones trascendentes o ambiguos. Es una revisión del razonamiento, no una revisión de salud determinista de la bóveda ni un flujo de reparación. Se activa con: piensa esto a fondo, piensa en profundidad, revisa la arquitectura, haz un postmortem, analiza ventajas y desventajas, cuestiona los supuestos."
---

# Pensar

Usa las diez etapas como un ciclo de atención, no como una transcripción
ceremonial. Ajusta la profundidad a la novedad, lo que está en juego, la
incertidumbre y la irreversibilidad. Mantén el resumen final del razonamiento
conciso y respaldado por evidencia.

Esta skill es de solo lectura. Puede inspeccionar la evidencia disponible, pero
no edita archivos, no ejecuta una modificación de la bóveda, no hace commit en
Git ni publica nada. Si la etapa CREAR recomienda un cambio, combínala con la
skill de modificación adecuada después de que el usuario autorice esa
operación.

## Establecer un marco de evidencia

Antes del ciclo, separa:

- **Observado:** respaldado directamente por una entrada, una fuente, una
  prueba o una medición.
- **Inferido:** una conclusión extraída de las observaciones; indica el puente.
- **Desconocido:** evidencia que falta y que podría cambiar la decisión.
- **Preferencia:** una elección del usuario o del diseñador, no una afirmación
  de hecho.

Adjunta citas o localizadores concretos cuando existan fuentes. Nunca inventes
una cita textual, un localizador, el resultado de una prueba, un consenso ni un
nivel de confianza.

## Las diez etapas

### 1. OBSERVAR: externo

Lee las entradas reales, el estado actual, las restricciones, los fallos y el
trabajo previo. Distingue lo que se inspeccionó por completo de lo que se
muestreó o se dio por supuesto.

### 2. OBSERVAR: interno

Nombra los sesgos con más probabilidad de distorsionar esta decisión: anclaje,
apropiación, novedad, familiaridad, urgencia, costo hundido, confirmación o un
veredicto deseado. Recalibra la confianza según la evidencia disponible.

### 3. ESCUCHAR

Recupera la intención del usuario, la condición de éxito, las restricciones y lo
que está en juego sin que se haya dicho. Presta atención a los mensajes de
error, la disidencia, los casos límite y las voces afectadas. Haz solo las
preguntas cuyas respuestas podrían cambiar de forma material el resultado.

### 4. PENSAR

Reduce el problema a invariantes, alternativas, compensaciones y modos de fallo.
Prefiere la prueba reversible más pequeña que pueda refutar la hipótesis
principal. Trata el comportamiento ante fallos como parte de la especificación.

### 5. CONECTAR: lateral

Busca la misma estructura en componentes adyacentes o en otro dominio. Usa una
analogía solo cuando sus similitudes y límites estén explícitos.

### 6. CONECTAR: sistema

Rastrea las entradas de origen, los consumidores posteriores, la propiedad, los
límites del estado, las interfaces y las rutas de recuperación. Comprueba si una
decisión sólida a nivel local crea una falla de integración en otra parte.

### 7. SENTIR

Considera la carga cognitiva del usuario, su estado emocional, la accesibilidad,
la confianza y la experiencia de recuperación ante errores. Trata la intuición
como una señal que investigar, nunca como un sustituto de la evidencia.

### 8. ACEPTAR

Expón con claridad las restricciones, la incertidumbre, la evidencia
contradictoria y los hallazgos desfavorables. No infles una puntuación, no
atenúes un riesgo importante para complacer al usuario ni confundas el acuerdo
con la corrección. Presenta el contraargumento razonable más sólido contra la
conclusión preferida.

### 9. CREAR

Produce el artefacto útil más pequeño: una recomendación, un documento de
decisión, un experimento, un borrador, una revisión o un traspaso. Marca los
supuestos y los riesgos sin resolver. No modifiques el estado con esta skill.

### 10. CRECER

Define qué retroalimentación o medición debería actualizar la decisión, cuándo
volver a revisarla y qué lección se puede reutilizar. Guardar la lección es una
operación explícita aparte, combinada con `save`.

## Disciplina de verificación

Antes de dar el trabajo por terminado:

1. Prueba la afirmación de mayor riesgo o indica con claridad por qué sigue sin
   probarse.
2. Busca evidencia que contradiga, no solo ejemplos que respalden.
3. Ajusta el esfuerzo de verificación al alcance del daño posible y a la
   reversibilidad.
4. Informa los comandos, las fuentes, los artefactos o las observaciones reales
   que usaste.
5. Separa una comprobación aprobada de la corrección más amplia que no
   establece.
6. Expresa la confianza como un juicio cualitativo calibrado y con razones, no
   como un porcentaje decorativo.

## Forma de la salida

Adapta los encabezados a la tarea, pero conserva estos resultados:

```markdown
## Decisión
<recomendación o artefacto>

## Evidencia
<hechos observados e inferencias importantes>

## Contraargumento y riesgos
<alternativa más sólida, contradicciones, incógnitas>

## Verificación
<comprobaciones realizadas y comprobaciones que aún hacen falta>

## Ciclo de crecimiento
<señal de retroalimentación, condición para revisar, lección reutilizable>
```

Para una consulta trivial y reversible, o para una errata, omite el ciclo
formal. Para una decisión importante, vuelve atrás cada vez que una etapa
posterior revele una observación que falta o un requisito mal entendido.
