# Personalización visual

Aplícala al crear la estructura inicial. Esto colorea el explorador de archivos según el tipo de carpeta y agrega estilos de destacados personalizados.

---

## Fragmento de CSS

Crea este archivo en `.obsidian/snippets/vault-colors.css` dentro de la bóveda:

```css
:root {
  --wiki-1: #4fc1ff;
  --wiki-2: #c586c0;
  --wiki-3: #dcdcaa;
  --wiki-4: #ce9178;
  --wiki-5: #6a9955;
  --wiki-6: #d16969;
  --wiki-7: #569cd6;
}

/* Folder colors in file explorer */
.nav-folder-title[data-path^="wiki/domains"]     { color: var(--wiki-1); }
.nav-folder-title[data-path^="wiki/entities"]    { color: var(--wiki-2); }
.nav-folder-title[data-path^="wiki/concepts"]    { color: var(--wiki-3); }
.nav-folder-title[data-path^="wiki/sources"]     { color: var(--wiki-4); }
.nav-folder-title[data-path^="wiki/questions"]   { color: var(--wiki-5); }
.nav-folder-title[data-path^="wiki/comparisons"] { color: var(--wiki-6); }
.nav-folder-title[data-path^="wiki/meta"]        { color: var(--wiki-7); }
.nav-folder-title[data-path=".raw"]              { color: #808080; opacity: 0.6; }

/* Custom callouts */
.callout[data-callout='contradiction'] {
  --callout-color: 209, 105, 105;
  --callout-icon: lucide-alert-triangle;
}
.callout[data-callout='gap'] {
  --callout-color: 220, 220, 170;
  --callout-icon: lucide-help-circle;
}
.callout[data-callout='key-insight'] {
  --callout-color: 79, 193, 255;
  --callout-icon: lucide-lightbulb;
}
.callout[data-callout='stale'] {
  --callout-color: 128, 128, 128;
  --callout-icon: lucide-clock;
}
```

---

## Activar el fragmento

Dile al usuario: Configuración > Apariencia > Fragmentos de CSS > abre la carpeta > pega el archivo > haz clic en el ícono de actualizar > actívalo.

---

## Grupos de la vista gráfica

Guía al usuario para configurarlos en los ajustes de la vista gráfica (haz clic en el ícono de configuración de la vista gráfica):

| Consulta | Color |
|-------|-------|
| `path:wiki/domains` | Azul (`#4fc1ff`) |
| `path:wiki/entities` | Morado (`#c586c0`) |
| `path:wiki/concepts` | Amarillo (`#dcdcaa`) |
| `path:wiki/sources` | Naranja (`#ce9178`) |
| `path:wiki/questions` | Verde (`#6a9955`) |
| `path:.raw` | Gris (atenuado) |

---

## Destacados personalizados

Esta bóveda define **cuatro tipos de destacados personalizados** además del conjunto integrado de Obsidian (`note`, `tip`, `warning`, `info`, `todo`, `success`, `question`, `failure`, `danger`, `bug`, `example`, `quote`). Se muestran correctamente **solo cuando `vault-colors.css` está activado**. Sin el fragmento, vuelven al estilo de destacado predeterminado (siguen siendo legibles, solo que sencillos).

| Destacado personalizado | Color | Ícono | Úsalo para |
|---|---|---|---|
| `contradiction` | marrón rojizo (rgb 209,105,105) | `lucide-alert-triangle` | Una fuente nueva entra en conflicto con una afirmación existente |
| `gap` | beige (rgb 220,220,170) | `lucide-help-circle` | El tema aún no tiene fuente |
| `key-insight` | azul brillante (rgb 79,193,255) | `lucide-lightbulb` | Conclusión importante que vale la pena resaltar |
| `stale` | gris (rgb 128,128,128) | `lucide-clock` | La afirmación puede estar desactualizada; fuente más antigua que el umbral |

### Uso

Úsalos en las páginas de la wiki para señalar estados importantes:

```markdown
> [!contradiction] Título
> [[Page A]] afirma X. [[Page B]] dice Y. Requiere resolución.

> [!gap] Título
> Este tema aún no tiene fuente. Conviene buscar una.

> [!key-insight] Título
> La conclusión más importante de esta sección.

> [!stale] Título
> Esta afirmación puede estar desactualizada. La fuente es de 2022.
```

### Por qué destacados personalizados (frente a los integrados)

Los cuatro tipos personalizados corresponden a conceptos propios de la wiki que no encajan bien en el conjunto predeterminado de Obsidian:

- `contradiction` es más específico que `warning`: señala un **conflicto resoluble** entre dos páginas de la wiki, no una advertencia genérica.
- `gap` es más específico que `question`: señala una **fuente faltante**, una mejora accionable.
- `key-insight` es más específico que `tip`: marca **la** conclusión más importante de una sección y se usa con moderación.
- `stale` no tiene equivalente integrado: señala el deterioro de una afirmación con el paso del tiempo.

Si no quieres destacados personalizados, reemplázalos por los integrados:
- `[!contradiction]` → `[!warning] Contradiction`
- `[!gap]` → `[!question] Gap`
- `[!key-insight]` → `[!tip] Key insight`
- `[!stale]` → `[!warning] Stale`

---

## Compatibilidad con temas

El fragmento usa variables CSS estándar y no requiere un tema de la comunidad.
Si el usuario elige un tema, verifica el contraste y el comportamiento de los
selectores en la versión de Obsidian instalada antes de recomendarlo para
trabajo sensible a la accesibilidad.
