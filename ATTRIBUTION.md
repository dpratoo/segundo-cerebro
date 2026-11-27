# Atribuciones

claude-obsidian es una obra original. Los siguientes patrones, herramientas y creadores de terceros influyeron en su diseño.

---

## Patrón LLM Wiki

**Autor:** Andrej Karpathy
**Fuente:** https://github.com/karpathy
**Uso:** La arquitectura central de claude-obsidian (usar un LLM para construir y mantener una wiki estructurada a partir de fuentes sin procesar) se basa en el patrón LLM Wiki que Karpathy describió públicamente. claude-obsidian es una implementación independiente; no se copió código ni contenido de los repositorios de Karpathy.

---

## Fragmentos de CSS ITS

**Autor:** SlRvb
**Fuente:** https://github.com/SlRvb/Obsidian--ITS-Theme
**Licencia:** GPL-2.0
**Archivos:**
- `.obsidian/snippets/ITS-Dataview-Cards.css`
- `.obsidian/snippets/ITS-Image-Adjustments.css`

Estos fragmentos existen solo en el estado privado de la bóveda de colaboradores.
No se seleccionan para el artefacto público determinista del producto ni los
instala la plantilla de bóveda. El fragmento `templates/vault/.obsidian/snippets/vault-colors.css`,
propio del proyecto, es el único fragmento que distribuye claude-obsidian.

---

## Complementos históricos de la bóveda de colaboradores

El repositorio de origen ha contenido los siguientes complementos comunitarios de
Obsidian en el estado de su bóveda de colaboradores. No se incluyen en el
artefacto público determinista del producto ni los instala la plantilla de
bóveda. Instálalos y revísalos a través de Obsidian bajo sus respectivas licencias.

| Complemento | Autor | Repositorio |
|-------------|-------|-------------|
| Calendar | Liam Cain | https://github.com/liamcain/obsidian-calendar-plugin |
| Thino | Boninall (Quorafind) | https://github.com/Quorafind/Obsidian-Thino |
| Obsidian Excalidraw | Zsolt Viczian | https://github.com/zsviczian/obsidian-excalidraw-plugin |
| Obsidian Banners | Danny Hernandez | https://github.com/noatpad/obsidian-banners |

`scripts/setup-vault.sh` no descarga binarios de complementos sin verificar. En su
lugar, imprime una guía de instalación manual.

---

## Diseños adoptados de colaboradores

Dos pull requests de la comunidad diagnosticaron errores de búsqueda y propusieron
correcciones que la refundación v2.0.0 implementó de forma casi idéntica. Los
pull requests no se fusionaron tal como se enviaron porque se reescribieron los
archivos circundantes, pero los diseños son suyos.

| Cambio | Colaborador | Pull request |
|--------|-------------|--------------|
| Prefijos de tarea Nomic `search_query` y `search_document` en el reordenador, incluida la función auxiliar `with_task_prefix` y la invalidación del esquema de caché | maartengoet | https://github.com/AgriciDaniel/claude-obsidian/pull/77 |
| Orden de la alternativa BM25 conservado en las rutas sin operación del reordenador (`bm25_score` antes de `score`) | vinsocci | https://github.com/AgriciDaniel/claude-obsidian/pull/62 |

La versión 3.0.0 también se apoya en las siguientes correcciones diagnosticadas y
propuestas. Estos créditos no implican que un pull request se haya fusionado o
aceptado sin revisión.

| Cambio o aporte de diseño | Colaborador | Pull request |
|--------|-------------|--------------|
| Dividir los destinos Markdown codificados antes de decodificar su ruta | Ychris12138 | https://github.com/AgriciDaniel/claude-obsidian/pull/194 |
| `_index.md` de Canvas, rutas que conservan el título y compatibilidad con el diario heredado | Marcos64s | https://github.com/AgriciDaniel/claude-obsidian/pull/199 |
| Migración del modelo Haiku 5.5 y del piso de caché, revisada aquí con límites explícitos de razonamiento y de salida | hphsu | https://github.com/AgriciDaniel/claude-obsidian/pull/195 |
| Nivel opcional de prefijos con Ollama local, reimplementado aquí de forma independiente con transporte acotado y comprobación previa del modelo local | vinsocci | https://github.com/AgriciDaniel/claude-obsidian/pull/63 |
| Las consultas de Dataview usan rutas de contenido relativas a la bóveda | miraclemanza | https://github.com/AgriciDaniel/claude-obsidian/pull/46 |

Estos pull requests de la comunidad se fusionaron tal como se enviaron.

| Cambio | Colaborador | Pull request |
|--------|-------------|--------------|
| Adaptador de host ZCode para el descubrimiento portátil de skills | Lion-1209 | https://github.com/AgriciDaniel/claude-obsidian/pull/146 |
| Un único vocabulario de tipos de página, para que el enrutador organice todos los tipos documentados | HectorBernstorff | https://github.com/AgriciDaniel/claude-obsidian/pull/149 |
| El lint ignora los candidatos ignorados por Git al resolver wikilinks ambiguos | Packetslave | https://github.com/AgriciDaniel/claude-obsidian/pull/159 |
| La ingesta prefiere enlaces Markdown para las URL citables | CooperSheroy | https://github.com/AgriciDaniel/claude-obsidian/pull/176 |
| Salida de pruebas en UTF-8 para que las ejecuciones de pruebas en Windows no fallen | yotamleo | https://github.com/AgriciDaniel/claude-obsidian/pull/178 |
| Los prefijos contextuales interpretan frontmatter con CRLF | ketpatil77 | https://github.com/AgriciDaniel/claude-obsidian/pull/180 |
| Bóvedas con estructura inicial fijadas al formato absoluto de wikilinks | tilusnet | https://github.com/AgriciDaniel/claude-obsidian/pull/182 |

La versión 2.2.0 también se apoya en estos pull requests, implementados aquí de forma independiente.

| Cambio | Colaborador | Pull request |
|--------|-------------|--------------|
| La raíz del repositorio ignora `.mcp.json`, un posible portador de credenciales | GPezzuti | https://github.com/AgriciDaniel/claude-obsidian/pull/44 |
| `stop_status` lee diarios válidos grandes en lugar de informar que no se pueden leer | STiFLeR7 | https://github.com/AgriciDaniel/claude-obsidian/pull/172 |
| `checkpoint` respeta los valores falsos de Git para `core.filemode` | STiFLeR7 | https://github.com/AgriciDaniel/claude-obsidian/pull/173 |

Estos informes de issues, varios con un diagnóstico o un parche probado, dieron
lugar a correcciones en la 3.0.0.

| Informe | Autor | Issue |
|---------|------------|-------|
| El lint dio por limpia una bóveda plana con 0 páginas analizadas | RoelKluin | https://github.com/AgriciDaniel/claude-obsidian/issues/200 |
| Decodificar antes de dividir el fragmento rompía los enlaces codificados con `%23` | threnard | https://github.com/AgriciDaniel/claude-obsidian/issues/193 |
| El lint informaba como archivos faltantes destinos `.raw` ocultos que sí existían | szrenwei | https://github.com/AgriciDaniel/claude-obsidian/issues/191 |
| Los hooks SessionStart y Stop agotaban el tiempo de espera en Windows | ppuri2 | https://github.com/AgriciDaniel/claude-obsidian/issues/168 |
| La detección del transporte de la CLI ignoraba si esta bóveda era accesible | cosmos75 | https://github.com/AgriciDaniel/claude-obsidian/issues/141 |
| Propuesta de glosario | simonc | https://github.com/AgriciDaniel/claude-obsidian/issues/25 |

Las referencias fijadas del ecosistema, las licencias y las diferencias
intencionales se registran en
[config/upstream-references.json](config/upstream-references.json). Los ejemplos
originales de la 3.0.0 no incorporan implementaciones restringidas de complementos
de terceros ni bóvedas personales de colaboradores.

---

## claude-obsidian

**Autor:** AgriciDaniel / AI Marketing Hub
**Licencia:** MIT (consulta [LICENSE](LICENSE))
**Repositorio (canónico público):** https://github.com/AgriciDaniel/claude-obsidian
**Espejo comunitario de acceso anticipado (Pro):** https://github.com/AI-Marketing-Hub

---

## Traducción al español

**Traducción y mantenimiento:** dpratoo  
**Repositorio:** https://github.com/dpratoo/segundo-cerebro  
**Base:** claude-obsidian v3.0.1 (commit `2e54556`) de AgriciDaniel, con licencia MIT.

La traducción cubre la documentación, las skills, los agentes, las plantillas,
las imágenes del README y los mensajes del código que se ven directamente. El
funcionamiento del plugin no cambia. Las fuentes incrustadas en los SVG del
README (Silkscreen, Geist, Geist Mono y Pixelify Sans) se distribuyen con la
SIL Open Font License 1.1.
