#!/bin/bash

# Script a cargo de comenzar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Start.sh RecPro
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh

if ambienteVacio; then 
	echo "Ambiente no inicializado. Ejecute IniPro"
	echo "No se realizó ninguna acción"
	exit 1
fi

PID=`ps aux | grep $BINDIR/$1.sh | grep -v grep | awk '{print $2}'`

if [ "$PID" != "" ]; then
    echo "El demonio ya se encuentra inicializado, no se realizó ninguna acción"
    exit 1
fi

nohup $1.sh > /dev/null 2>&1 &

PID=`ps aux | grep $BINDIR/$1.sh | grep -v grep | awk '{print $2}'`

if [ "$PID" != "" ]; then
    echo "Se inició el demonio correctamente con PID: $PID" 
    exit 0
fi

echo "Error al iniciar el demonio"
exit 1


