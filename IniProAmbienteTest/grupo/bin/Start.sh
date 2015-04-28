#!/bin/bash

# Script a cargo de comenzar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Start.sh
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh

if ambienteVacio; then 
	echo "Ambiente no inicializado. Ejecute IniPro"
	echo "No se realizó ninguna acción"
	exit 1
fi


PID=`pidof RecPro.sh`


if [ "$PID" != "" ]; then
    echo "El demonio ya se encuentra inicializado, no se realizó ninguna acción"
    exit 1
fi

#nohup RecPro.sh > /dev/null 2>&1 &

PID=`pidof $BINDIR/RecPro.sh`

if [ "$PID" != "" ]; then
    echo "Se inició el demonio correctamente con PID: $PID" 
    exit 0
fi

echo "Error al iniciar el demonio"
exit 1


