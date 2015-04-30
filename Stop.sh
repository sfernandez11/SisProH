#!/bin/bash

# Script a cargo parar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Stop.sh RecPro
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh

if [ ! -f $BINDIR/$1.sh ]; then
    echo "No existe script $1"
    exit 1
fi

#PID=`ps aux | grep "\($BINDIR\)\?/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
PID=$(getPid $1)

if [ "$PID" != "" ]; then
    echo "Deteniendo proceso con pid $PID .."
    kill -9 $PID
    
    if [ $? -ne 0 ];
    then
        echo "Error al detener el demonio con pid $PID"    
    fi

    #PID=`ps aux | grep "\($BINDIR\)\?/$1.sh" | grep -v grep | awk '{print $2}'`
    #PID=`ps aux | grep "\($BINDIR\)\?/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    PID=$(getPid $1)

    if [ "$PID" != "" ]; then
        echo "No se pudo detener el demonio"    
        exit 1
    fi

    echo "Se detuvo el demonio"
    exit 0
fi
