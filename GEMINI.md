# claude-obsidian: instrucciones para Gemini

Lee `AGENTS.md` como el contrato canónico independiente del host. Las skills viven
en `skills/<name>/SKILL.md` y el núcleo portátil vive en `claude_obsidian/`.

Instala el descubrimiento de skills con:

```bash
bash scripts/setup-multi-agent.sh --host gemini
bash scripts/setup-multi-agent.sh --host gemini --apply
```

El primer comando muestra una vista previa de los enlaces; el segundo aplica ese
alcance ya revisado.

Este repositorio es la fuente del producto, no la bóveda de usuario por defecto.
Crea una bóveda aparte con el comando `init`, que primero hace una simulación, o
adopta una bóveda existente. Resuelve esa bóveda antes de leer `wiki/hot.md` o
ejecutar una skill.

Toda modificación compartida usa un único paquete `claude-obsidian.transaction.v1`
inspeccionado. Los agentes en paralelo solo redactan borradores. No uses
escrituras compartidas directas, commits automáticos ni el auxiliar obsoleto de
bloqueo por archivo. La salida de red remota y las acciones destructivas necesitan
el consentimiento explícito del usuario.

Repositorio canónico público: https://github.com/dpratoo/segundo-cerebro
