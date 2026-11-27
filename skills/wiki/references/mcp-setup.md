# Transportes de lectura externos

La base portátil lee directamente los archivos de la bóveda. La CLI oficial de
Obsidian es una superficie de lectura opcional cuando la sonda en tiempo de
ejecución informa que se puede usar. Los servidores MCP y los complementos REST
son integraciones opcionales de terceros, nunca requisitos previos.

## Política de selección

1. Prefiere las lecturas directas del sistema de archivos por portabilidad y por
   mínimo privilegio.
2. Usa la CLI oficial de Obsidian en modo de solo lectura cuando
   `detect-transport.sh --peek` informe que se puede usar.
3. Considera un adaptador MCP o REST solo cuando el usuario necesite una
   capacidad que las dos primeras opciones no puedan ofrecer y apruebe de forma
   explícita la instalación.
4. Mantén todas las modificaciones de la bóveda dentro de una transacción de
   operación de claude-obsidian. Un transporte externo no debe eludir los
   hashes esperados, el diario ni la recuperación.

## Revisión de terceros

Las recetas de instalación, los nombres de paquetes, los flags y los permisos
cambian. Consulta la documentación principal vigente del adaptador antes de
usarlo, fija una versión revisada y verifica el publicador y el origen. No
ejecutes paquetes flotantes `latest`, descargas no verificadas ni scripts de
instalación opacos a partir de esta referencia.

Para cualquier adaptador:

- concede acceso solo a la bóveda seleccionada;
- vincula los oyentes de red a loopback, a menos que el usuario haya diseñado y
  aprobado un acceso remoto autenticado;
- mantén los tokens fuera de las notas, del historial del shell, de las
  bitácoras y de los archivos del repositorio;
- conserva la verificación de TLS en lugar de usar variables de entorno globales
  que la omitan;
- usa solo lectura por defecto y prueba con datos no sensibles;
- documenta qué datos pueden salir de la máquina y cómo desactivar el adaptador.

Vincular a loopback reduce la exposición, pero no vuelve seguros una verificación
de certificados desactivada ni unos tokens de portador filtrados.

## Verificación

Informa que un adaptador está listo solo después de que una sonda de lectura
inofensiva tenga éxito. La sola presencia del binario o de la configuración
significa `available`, no `verified`. Si una sonda falla, recurre a las lecturas
del sistema de archivos sin cambiar la semántica de las modificaciones.
