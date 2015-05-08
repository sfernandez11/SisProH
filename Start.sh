#!/bin/bash

# Script a cargo de comenzar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ Start.sh RecPro
#
# Si se llama desde un script, pasar su nombre como segundo parametro:
# "Start.sh RecPro IniPro"
#------------------------------------------------------------------------------------------------------------

source commonFunctions.sh

CALLER=$2

# 1=loglevel 2=message
function log(){
	if [ "$CALLER" == "" ]; then
		echo "[$1] $2"
	else
		echo "[$1] $2"
		glog.sh "$CALLER" "$2" "$1"
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
    log "WAR" "El demonio ya se encuentra inicializado (PID=$PID), no se realizó ninguna acción"
    exit 1
fi
echo Iniciando $1 . . .
nohup $1.sh > /dev/null 2>&1 &
sleep 1
PID=$(getPid $1)

if [ "$PID" != "" ]; then
    log "INFO" "Se inició el demonio correctamente con PID: $PID" 
    log "INFO" "Para detenerlo ejecute $ Stop.sh $1"
    exit 0
else 
	log "ERR" "Error al iniciar el demonio"
	exit 1
fi
