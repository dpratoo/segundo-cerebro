---
name: Reporte de error
about: Algo está roto o se comporta de forma inesperada
title: "[bug] "
labels: bug
assignees: ''
---

## Qué ocurrió
Una descripción clara del comportamiento inesperado.

## Comportamiento esperado
Lo que esperabas que ocurriera en su lugar.

## Pasos para reproducirlo
1. ...
2. ...
3. ...

## Entorno
- Versión del producto: (ejecuta `python3 scripts/claude-obsidian.py --version`)
- Versión de Claude Code: (ejecuta `claude --version`)
- Sistema operativo: (por ejemplo, macOS 14.5, Pop!_OS 24.04, Windows 11)
- Versión de Obsidian: (si es relevante)
- Origen de la selección de la bóveda: (salida de `doctor --vault <vault>`, con las rutas privadas ocultas)
- Estado del transporte: (salida de `bash scripts/detect-transport.sh --peek --vault <vault>`)

## Skill, agente o script involucrado
¿Qué superficie está afectada? (por ejemplo, `/claude-obsidian:wiki-ingest`, `scripts/wiki-mode.py`, `agents/verifier.md`)

## Salida o mensajes de error
```
Paste relevant terminal output or error messages here.
```

## Qué intentaste
- [ ] Ejecuté la prueba de regresión relevante o `make test`: Sí / No
- [ ] Confirmé que el repositorio del producto y la bóveda del usuario están separados: Sí / No
- [ ] Revisé en CHANGELOG si hay problemas conocidos en mi versión
- [ ] Busqué reportes similares en los issues existentes

## Contexto adicional
Cualquier otra cosa que pueda ayudar (capturas de pantalla, issues relacionados, cambios recientes).
