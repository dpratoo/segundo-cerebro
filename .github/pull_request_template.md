# Pull request

## Resumen
Una descripción de un párrafo de lo que cambia este PR y por qué.

## Tipo
- [ ] Corrección de error (`fix:`)
- [ ] Función nueva (`feat:`)
- [ ] Documentación (`docs:`)
- [ ] Refactorización (`refactor:`)
- [ ] Cobertura de pruebas (`test:`)
- [ ] Tareas varias, compilación o mantenimiento (`chore:`)

## Issue relacionado
Cierra #<número-del-issue> (si corresponde)

## Cambios
Enumera los archivos y superficies tocados:
- `skills/<name>/SKILL.md`: qué cambió
- `scripts/<name>.py`: qué cambió
- ...

## Autorrevisión de seguridad
- [ ] Leí cada archivo antes de cambiarlo
- [ ] Los identificadores nuevos tienen nombres pensados para el siguiente lector
- [ ] La unidad más pequeña que funciona (sin abstracción especulativa)
- [ ] Las eliminaciones acompañan a las adiciones cuando corresponde
- [ ] El comportamiento nuevo tiene cobertura de pruebas herméticas
- [ ] Los modos de fallo nuevos tienen manejo explícito y un plan de reversión
- [ ] El código del producto y el estado mutable de la bóveda del usuario siguen separados
- [ ] Las escrituras de conocimiento usan una única transacción recuperable; los agentes solo redactan borradores
- [ ] Las acciones de red, destructivas o externas tienen consentimiento explícito
- [ ] Las afirmaciones y la madurez de las capacidades están respaldadas por evidencia

## Pruebas
```
make test
```
Pega aquí el final de la salida (o un resumen si es muy larga):

```
All tests passed.
```

## Verificador
Para cambios no triviales, ejecuta `agents/verifier.md` sobre el árbol de trabajo o el alcance de rutas declarado y pega su veredicto:

- Veredicto: SHIP / HOLD-FIX-FIRST / NEEDS-REWORK
- BLOCKER: N / HIGH: N / MEDIUM: N / LOW: N

## CHANGELOG
- [ ] Agregué una entrada bajo `## [Unreleased]` en `CHANGELOG.md`

## Capturas de pantalla o salida
Si el cambio afecta la salida visible para el usuario, pega un ejemplo de antes y después.

## Notas para quien revise
Cualquier punto específico en el que deba concentrarse quien revise, o contexto que no sea evidente en el diff.
