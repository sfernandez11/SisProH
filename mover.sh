#!/bin/bash

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
if [ $# -eq 3 ] 		#Si hay 3 parametros significa que se ingreso el nombre del comando.
then

	COMANDO=$3			#Se asigna el nombre del comando con la variable.

elif [ $# -eq 2 ]		#Si hay 2 parametros solo se ingreso el origen y el destino.
then

	COMANDO="Mover"		#En este caso los errores van al log del Mover.

else

	# Si no hay ni 2 o 3 parametros significa que hay un error: "Parametros invalidos"
	$BINDIR/glog.sh "Mover" "Recibidos $# parametros en lugar de 2 o 3" "ERR"
	exit -1

fi

#Se asignan los datos ingresados con las variables.
ORIGEN=$1
DESTINO=$2

if [ "$ORIGEN" == "$DESTINO" ] 	#Se verifica si el directorio origen y destino son iguales.
then

	#Si el origen y el destino son iguales, no mover y registrar en el log el error
	$BINDIR/glog.sh "$COMANDO" "El Origen y el Destino son iguales" "ERR"
	exit -2

fi

NOMBRE_ARCHIVO="${ORIGEN##*/}"
_DUPDIR="${DUPDIR##*/}"

if [ ! -f "$ORIGEN" ] 		#Verifica si existe el archivo en el origen.
then

	# Si el origen no existe, no mover y registrar en el log el error
	$BINDIR/glog.sh "$COMANDO" "No existe el archivo origen que se quiere mover" "ERR"
	exit -3 

elif [ ! -d "$DESTINO" ]	#Verifica si existe el directorio destino.
then

	# Si el destino no existe, no mover y registrar en el log el error
	$BINDIR/glog.sh "$COMANDO" "No existe el destino al que se quiere mover el archivo" "ERR"
	exit -4 

else

	#Me fijo si ya existe en el destino un archivo con el mismo nombre del archivo que se quiere mover.
	OCURRENCIA=$(ls "$DESTINO" | grep -c "${NOMBRE_ARCHIVO}")

	#Si hay alguna ocurrencia.
	if [ "$OCURRENCIA" -ne 0 ]
	then
        
        #Si no existe el directorio de DUPDIR en el destino.
		if [ ! -d "${DESTINO}/$_DUPDIR" ]
		then

			mkdir "${DESTINO}/$_DUPDIR" 	#Entonces lo creo.

		fi

		#TODO: FALTA MODIFICAR ESTO DE LA SECUENCIA, DEBERIA SER .NNN Y NO LA FECHA
		#Uso la fecha ahora solo como prueba hasta ver bien lo de la SECUENCIA.
		SECUENCIA="$(date '+%Y-%m-%d-%H:%M:%S')"

		#Muevo el archivo duplicado al directorio DUPDIR con un cambio de nombre que se le agrega una secuencia.
		mv "${DESTINO}/$NOMBRE_ARCHIVO" "${DESTINO}/$_DUPDIR/${NOMBRE_ARCHIVO}.$SECUENCIA"

	fi

	#Si no esta repetido el archivo en el directorio destino muevo el archivo.
	mv "$ORIGEN" "$DESTINO"
	
	exit 0

fi