# Referencia opcional de Dataview

Úsala solo cuando el usuario ya tenga Dataview y pida una consulta compatible.
El núcleo portátil no necesita ningún complemento comunitario. Prefiere una Base
nativa cuando sea suficiente. No instales Dataview como efecto secundario.

DQL resuelve las fuentes de carpeta desde la raíz de la bóveda, sin importar la
ubicación de la nota del panel. Este ejemplo original enumera los conceptos
canónicos dentro de `wiki/`:

```dataview
TABLE type, status, updated
FROM "wiki"
WHERE type = "concept"
SORT file.name ASC
```

Una tabla vacía solo significa que no hay notas indexadas coincidentes cuando el
complemento está presente, habilitado y con su índice actualizado. De lo
contrario, informa que no está disponible o que no está verificado. El ejemplo
usa propiedades almacenadas, no afirma que las propiedades sean verdaderas. Los
campos `file` de Dataview no son sintaxis de fórmulas de Bases.

La consulta es un ejemplo de visualización declarativo, no una prueba ejecutable
de Python. Las comprobaciones sin conexión validan su alcance de fuente y las
propiedades referenciadas contra las notas fixture incluidas. El renderizado
nativo de Dataview sigue requiriendo el complemento y una observación de la
aplicación con versión; consulta
[native-conformance.md](../../../docs/native-conformance.md).

No ejecutes `dataviewjs` ni consultas importadas durante la ingesta ni en el
trabajo normal de consulta o lint. Conserva byte a byte el DQL y los bloques
ejecutables existentes en las ediciones no relacionadas. DataviewJS puede
realizar operaciones de archivos y de red.

Referencia revisada el 2026-10-17: [documentación de Dataview](https://blacksmithgu.github.io/obsidian-dataview/queries/query-types/)
y [README en el commit fijado](https://github.com/blacksmithgu/obsidian-dataview/blob/5ad0994ff384cbb797de382e7edff2388141b73a/README.md).
Esta receta está escrita de forma independiente y no importa ningún código del
complemento.
