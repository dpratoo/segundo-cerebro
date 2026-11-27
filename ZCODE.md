# claude-obsidian: instrucciones para ZCode

Lee `AGENTS.md` como el contrato canónico independiente del host. Las skills viven
en `skills/<name>/SKILL.md` y el núcleo portátil vive en `claude_obsidian/`.

ZCode lee `AGENTS.md` de forma nativa en el ámbito del espacio de trabajo y del
usuario (según la documentación de agentes de ZCode, https://zcode.z.ai/en/docs/agents),
por lo que no hace falta un archivo de reglas reflejado. Las skills de nivel de
usuario se descubren en `~/.zcode/skills/<skill-name>/SKILL.md`
(https://zcode.z.ai/en/docs/skill). Instala el descubrimiento de skills con:

```bash
bash scripts/setup-multi-agent.sh --host zcode
bash scripts/setup-multi-agent.sh --host zcode --apply
```

El primer comando muestra una vista previa de los enlaces; el segundo aplica ese
alcance ya revisado. Los enlaces quedan en `~/.zcode/skills/` (nivel de usuario),
de modo que cualquier espacio de trabajo de ZCode puede invocar las skills sin
configuración por proyecto.

Este repositorio es la fuente del producto, no la bóveda de usuario por defecto.
Crea una bóveda aparte con el comando `init`, que primero hace una simulación, o
adopta una bóveda existente. Resuelve esa bóveda antes de leer `wiki/hot.md` o
ejecutar una skill.

Toda modificación compartida usa un único paquete
`claude-obsidian.transaction.v1` inspeccionado. Los agentes en paralelo solo
redactan borradores. No uses escrituras compartidas directas, commits
automáticos ni el script auxiliar obsoleto de bloqueo por archivo. La salida de
red remota y las acciones destructivas necesitan el consentimiento explícito del
usuario.

Repositorio canónico público: https://github.com/dpratoo/segundo-cerebro
