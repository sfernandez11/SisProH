#!/bin/bash

# Script a cargo parar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Stop.sh
#------------------------------------------------------------------------------------------------------------

PID=`pidof RecPro.sh`

if [ "$PID" != "" ]; then
	kill -9 $PID
	PID=`pidof RecPro.sh`
	if [ "$PID" != "" ]; then
	    echo "No se pudo detener el demonio"    
    	exit 1
    fi
    echo "Se detuvo el demonio"
    exit 0
fi