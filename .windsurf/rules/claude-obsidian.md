# claude-obsidian: reglas para Windsurf

Lee `AGENTS.md` como el contrato canónico independiente del host. Previsualiza y
luego instala los enlaces de skills de Cascade con
`bash scripts/setup-multi-agent.sh --host windsurf --workspace "$PWD"` seguido del
mismo comando con `--apply`, y carga el `skills/<name>/SKILL.md` correspondiente
cuando una solicitud lo active.

El clon del producto y la bóveda del usuario son independientes. Resuelve la
bóveda del usuario antes de leer el contexto caliente o de modificar el
conocimiento. Las cargas sin procesar son solo de creación; los agentes en
paralelo devuelven borradores; un orquestador inspecciona y aplica una única
transacción recuperable. Las consultas y el lint siguen siendo de solo lectura. La
salida de red, la reparación destructiva y los puntos de control de Git requieren
consentimiento explícito del usuario.

Repositorio canónico público: https://github.com/dpratoo/segundo-cerebro
