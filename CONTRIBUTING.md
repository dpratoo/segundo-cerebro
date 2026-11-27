# Contribuir a claude-obsidian

Las contribuciones son bienvenidas en el repositorio canónico público:
https://github.com/dpratoo/segundo-cerebro.
Este repositorio mantiene la traducción al español. Los cambios de
funcionamiento (código, pruebas, contratos) corresponden al proyecto original:
https://github.com/AgriciDaniel/claude-obsidian.

Para un cambio sustancial, abre un issue que describa el problema del usuario, el
comportamiento propuesto, el impacto en la compatibilidad, las implicaciones de
privacidad y de salida de red, y una estrategia de pruebas herméticas. Los
reportes de seguridad siguen [SECURITY.md](SECURITY.md), no el rastreador público
de issues.

## Contrato de ingeniería

- Lee el comportamiento afectado, sus llamadores, los contratos y las pruebas
  antes de editar.
- Mantén separados el código del producto y el estado de la bóveda del usuario.
- Prefiere la implementación determinista más pequeña, con un comportamiento
  explícito de fallo y de recuperación.
- Conserva los archivos existentes del usuario, salvo que el usuario revise un
  reemplazo explícito o un plan destructivo.
- Encauza cada modificación lógica de conocimiento por una única transacción
  recuperable.
- Limita a los agentes en paralelo a redactar borradores y mantén las
  operaciones de consulta y de lint en solo lectura.
- Exige consentimiento explícito para la salida de red remota, las reparaciones
  destructivas y los cambios de estado externos.
- No agregues afirmaciones de capacidad, rendimiento o comparación con la
  competencia sin evidencia actual y trazable.
- Mantén el frontmatter de las skills en exactamente `name` y `description`.

## Flujo de trabajo local

Crea una rama específica desde un fork público. Se requiere Python 3.11 o
posterior. La rama predeterminada pública es un árbol de producto limpio de
artefactos y autovalidante; nunca agregues a una contribución el estado de bóveda
de la raíz (`wiki/`, `.raw/` o `.vault-meta/`).

```bash
make test
```

El objetivo de pruebas descubre cada archivo `tests/test_*.py` y `tests/test_*.sh`
y luego ejecuta los contratos de producto y capacidades y los de paquete. Las
pruebas deben ser herméticas: sin red, servidor de modelos, rutas personales,
configuración global ni estado persistente del producto. Una integración de red
va detrás de un indicador de consentimiento explícito y necesita un doble de
prueba sin conexión.

Los cambios de comportamiento deberían incluir:

1. una prueba de regresión que falle con el comportamiento anterior;
2. cobertura de éxito, conflicto, entrada no válida y recuperación proporcional al
   riesgo;
3. documentación de usuario y de contratos actualizada;
4. una entrada bajo `## [Unreleased]` en `CHANGELOG.md`.

Ejecuta el verificador de solo lectura con contexto nuevo de `agents/verifier.md`
en los cambios no triviales. Puede inspeccionar todo el árbol de trabajo o un
alcance de rutas declarado; nunca prepara cambios, hace commits, hace push ni
modifica archivos. Resuelve los hallazgos BLOCKER y HIGH antes de solicitar la
revisión.

Usa Conventional Commits cuando sea práctico. El pull request debería explicar el
problema, el comportamiento, la historia de compatibilidad y reversión, la
verificación exacta ejecutada y cualquier limitación pendiente. No incluyas
contenido de la bóveda, credenciales, estado de ejecución generado ni binarios
sin revisar.

Al contribuir, aceptas que tu contribución se licencia bajo la
[Licencia MIT](LICENSE) y se rige por [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
