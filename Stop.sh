#!/bin/bash

# Script a cargo parar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Stop.sh RecPro
#------------------------------------------------------------------------------------------------------------

source commonFunctions.sh

CALLER=$2

# 1=loglevel 2=message
function log(){
    if [ "$CALLER" == "" ]; then
        echo "[$1] $2"
    else
        echo "[$1] $CALLER $2"
        $BINDIR/glog.sh "$CALLER" "$2" "$1"
    fi
}

if ! environmentNotEmpty; then 
    log "ERR" "Ambiente no inicializado. Ejecute IniPro"
    log "INFO" "No se realizó ninguna acción"
    exit 1
fi

if [ ! -f $BINDIR/$1.sh ]; then
    log "ERR" "No existe script $1"
    exit 1
fi

PID=$(getPid $1)

if [ "$PID" != "" ]; then
    log "ERR" "Deteniendo proceso con pid $PID .."
    kill -9 $PID
    
    if [ $? -ne 0 ];
    then
        log "ERR" "Error al detener el demonio con pid $PID"    
    fi

    PID=$(getPid $1)

    if [ "$PID" != "" ]; then
        log "ERR" "No se pudo detener el demonio"    
        exit 1
    fi

    log "ERR" "Se detuvo el demonio"
    exit 0
fi
