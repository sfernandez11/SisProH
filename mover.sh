#!bin/bash

# Script a cargo del movimiento de archivos entre directorios
#-----------------------------------------------------------------------------------------------------------
# ¿Como usar el script?
# >$ ./mover.sh ORIGEN DESTINO COMANDO(OPCIONAL)
#
# El script recibe 2 o 3 parametros:
# 1°: directorio original donde se encuentra el archivo 
# 2°: directorio destino donde se quiere mover el archivo.
# 3° (opcional): nombre de la funcion o comando que la invoca.
#
# ¿Que hace/retorna?
#  - Si el archivo no exite en el directorio destino, simplemente lo mueve y retorna 0 (cero).
#  - Si el archivo ya existe en el directorio destino, crea (si no esta creado) un directorio 
#		dentro del directorio destino (DUPDIR) y hace una copia del duplicado, agregandole un número de 	
#		secuencia al final del nombre del archivo duplicado y luego mueve el archivo pedido al directorio
#		destino, retornando 0 (cero). 
#  - Si hay problemas con los parametros recibidos retorna un valor distinto de 0 (cero).
#  - Si hay otro tipo de problema siempre se va a logear en el log del comando que ejecuto la funcion mover, en
#		caso de que no se pase el nombre del comando, por defecto se escribe en el log de mover.
#------------------------------------------------------------------------------------------------------------

