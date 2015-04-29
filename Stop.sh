#!/bin/bash

# Script a cargo parar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Stop.sh RecPro
#------------------------------------------------------------------------------------------------------------


PID=`ps aux | grep $BINDIR/$1.sh | grep -v grep | awk '{print $2}'`

if [ "$PID" != "" ]; then
	kill -9 $PID

	PID=`ps aux | grep $BINDIR/$1.sh | grep -v grep | awk '{print $2}'`

	if [ "$PID" != "" ]; then
	    echo "No se pudo detener el demonio"    
    	exit 1
	fi

    echo "Se detuvo el demonio"
    exit 0
fi
