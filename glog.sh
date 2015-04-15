#!/bin/bash

# Script a cargo del log de los diferentes comandos o funciones.
#-------------------------------------------------------------------------------------------------------
# El script recibe 2 o 3 parametros:
# 1°: nombre de la funcion o comando que llama al log.
# 2°: un string con el mensaje propiamente dicho a loguear.
# 3° (opcional): tipo de error: INFORMATIVO(INFO), WARNING(WAR) o ERROR(ERR).

# De no recibir el 3° parametro, se asume que el valor por dafault es INFO.
# Ademas, como dice el enunciado, el log tiene el mismo nombre que la funcion/comando que llama a este script
# con la extension .log y que la ubicacion es LOGDIR o bien CONFDIR si se trata del comando InsPro.
#------------------------------------------------------------------------------------------------------

WHERE=$1 			# Nombre de la funcion o comando que llama al glog.
WHY=$2 				# Texto del mensaje a loguear.

if [ $# -eq 3 ]		# Si hay 3 parametros significa que se identifica el tipo de error.
then
	WHAT=$3 		# Tipo de error: INFO, WAR o ERR

elif [ $# -eq 2 ] 	# Si hay 2 parametros se toma la variable WHAT = INFO por default.
then 

	WHAT="INFO" 	# Tipo de error: INFO por default.

	#Me fijo si el log es el del instalador u otro comando/funcion.
	if [ "$WHERE" = "InsPro" -o "$WHERE" = "INSPRO" -o "$WHERE" = "inspro" ]
	then

		LOGPATH="$CONFDIR/InsPro.log"

	else

		LOGPATH="$LOGDIR/$WHERE.log"

	fi

else

	# Si la cantidad de parametros es incorrecta
	$BINDIR/glog.sh "Glog" "ERR" "Recibidos $# parametros en lugar de 2 o 3"	# Llamada recursiva que loguea error en los parametros del log.

	exit $#				# El codigo de error es la cantidad de parametros recibidos.

fi


WHEN=`date`				# Fecha y Hora, en el formato que deseen y calculada justo antes de la grabación.
WHO=$LOGNAME			# Usuario, es el login del usuario.


#Usos de >> y >:
# >>: Ej: echo data >> data.txt  Agrega data al final de data.txt y crea el archivo si no existe.
# >:  Ej: echo data > data.txt   Crea, si no existe, un archivo data.txt y agrega data. Si existe lo sobreescribe.

# Escritura en log: 
#Ej: 20150505 19:53:22-alumnos-IniPro-WAR-No se pudo arrancar RecPro.
echo "$WHEN-$WHO-$WHERE-$WHAT-$WHY" >> $LOGPATH


# Manejo de crecimiento controlado:
# TODO: queda revisar esta parte.
# TAMANO=`stat -c %s $LOGPATH` 				#Comando que indica el tamaño de un archivo. Devuelve el tamaño en bytes.

# if [ $TAMANO -gt $LOGSIZE ] 				#Si el tamaño del archivo es mayor que el LOGSIZE
# then
# 	TEMPORAL='templog.log'					#Creo un archivo temporal para el log nuevo.
#	echo " Log Excedido. " >> $TEMPORAL 	#Agrego como primera linea al archivo "Los Excedido" para indicar que se realizo este procedimiento.
# 	tail -n 50 $LOGPATH >> $TEMPORAL		#Agrego las ultimas 50 lineas del log viejo al nuevo.
#	rm $LOGPATH								#Elimino el viejo log
#	mv $TEMPORAL $LOGPATH					#Cambia el nombre del archivo de templog al original.
# fi

exit 0