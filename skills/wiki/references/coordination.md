# Editores externos y varias máquinas

El bloqueo de modificación local serializa a los escritores cooperantes de
claude-obsidian sobre la bóveda local seleccionada. Las precondiciones de SHA-256
esperado detectan destinos modificados en el momento de la inspección o de la
aplicación. Obsidian, otros editores, los clientes de sincronización y otras
máquinas no adquieren ese bloqueo. Un archivo todavía puede cambiar después de
una comprobación. Esto no es un protocolo de fusión entre dispositivos ni de
bloqueo distribuido.

Para una operación que cambia notas o registros:

1. Termina las ediciones y espera a que la sincronización se estabilice en cada
   dispositivo. Conserva una copia de seguridad recuperable. Elige una sola
   máquina como único escritor de la operación.
2. Pausa los escritores de complementos que se solapen y los puntos de control en
   segundo plano. Evita editar en Obsidian los archivos de destino mientras se
   aplica una transacción revisada.
3. Lee y calcula el hash de los destinos, inspecciona una sola vez y aplica el
   paquete aprobado exacto. El código de salida 75 exige una lectura nueva y un
   plan reconstruido; no reintentes escrituras obsoletas.
4. Verifica el comprobante, las rutas que cambiaron, los bytes de las fuentes y
   el lint determinista antes de reanudar la sincronización. Conserva la
   evidencia de la operación fuera de la bóveda que se sincroniza si hace falta.
5. Reanuda los demás escritores solo después de que todos los dispositivos
   converjan en los bytes verificados. Las copias en conflicto necesitan una
   revisión aparte que preserve la evidencia, no una sobrescritura por parte del
   último escritor. Nunca borres contenido sin procesar para que desaparezca un
   conflicto de sincronización.

Si la sincronización interrumpe una aplicación, detén los escritores que
compiten, conserva juntos la bóveda completa y el diario de `.vault-meta/`, y
usa `transaction recover`. No sincronices la mitad de un diario por separado de
sus destinos y copias de seguridad. No fuerces un bloqueo obsoleto hasta que un
operador haya confirmado de forma independiente que no hay ningún escritor
activo.

Estos pasos reducen los solapamientos; las pruebas sin conexión no afirman
ninguna convergencia real de sincronización en la nube ni de sistemas de
archivos en red. Un ETag de REST protege una operación de transporte y no puede
sustituir al diario de varios archivos, a los hashes locales ni al acuerdo de un
único escritor. Las lecturas del sistema de archivos o de la CLI siguen siendo
preferibles cuando un transporte opcional no aporta valor.
