#!/bin/bash

# Script que instala el sistema
#-----------------------------------------------------------------------------------------------------------
# Uso:
# >$ ./InsPro.sh
#
# El script no recibe parametros:
#
# Funcion:
#  - Verifica que el sistema cumpla las condiciones para instalar
#  - Instala
#------------------------------------------------------------------------------------------------------------

# importo mi archivo con funciones
source InsFunctions.sh

GRUPO=$PWD/grupo02
CONFDIR=conf

# TODO: verificar si ya esta instalado y cosas que faltan instalar
if [ -f $GRUPO/$CONFDIR/InsPro.conf ]
then
  echo "Ya esta instalado."
  exit 0
else
  # valores por defecto de las variables de ambiente

  MAEDIR=mae
  NOVEDIR=novedades
  ACEPDIR=a_protocolarizar
  RECHDIR=rechazados
  PROCDIR=protocolizados
  INFODIR=informes
  DUPDIR=dup
  LOGDIR=log
  BINDIR=bin
  DATASIZE=100
  LOGSIZE=400
fi

# TODO: CONFDIR ya deberia existir
createDirs $CONFDIR


# valido version de perl

if [ -z $(getPerlVersion) ]
then
  logError "No tiene instalado perl"
  exit 1
fi

if noCompatiblePerlVersion;
then
  logError "Se requiere perl 5 o superior"
  exit 1
fi


CONFIRM_INSTALL=""
until [ "$CONFIRM_INSTALL" = "SI" -o "$CONFIRM_INSTALL" = "S" ]
do
  if [ -n "$CONFIRM_INSTALL" ]
  then
    # limpio la pantalla
    printf "\033c"
    logInfo "Instalacion reiniciada .."
  fi
  # pido al usuario que ingrese los valores de las variables
  setDir MAEDIR "maestros y tablas"
  setDir BINDIR "instalación de los ejecutables"
  setDir NOVEDIR "recepción de documentos para protocolización"
  setDir ACEPDIR "grabación de las Novedades aceptadas"
  setDir RECHDIR "grabación de Archivos rechazados"
  setDir PROCDIR "grabación de los documentos protocolizados"
  setDir INFODIR "grabación de los informes de salida"
  setDir DUPDIR "repositorio de archivos duplicados"
  setDir LOGDIR "logs"
  setVariable LOGSIZE "tamaño máximo para cada archivo de log en Kbytes"
  setVariable DATASIZE "espacio mínimo libre para el arribo de las novedades en Mbytes"

  # se hacen todas las validaciones

  # valido espacio en disco
  current_free_space=$(freeSpace $PWD)

  if [ $current_free_space -le $DATASIZE ]
  then
    logError "espacio requerido $DATASIZE Mb"
    logError "espacio insuficiente en disco"
    logError "espacio que tengo $current_free_space Mb"
    exit 1
  fi

  # se cumplieron todas las validaciones confirmo inicio
  showStatus
  logInfo "Inicia la instalación? Si / No: "
  read -n 2 -p '    Si / No (Si): ' CONFIRM_INSTALL

  CONFIRM_INSTALL=`echo $CONFIRM_INSTALL | tr '[:lower:]' '[:upper:]' | sed s:^$:SI:`

done

# creacion de directorios
createDirs $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR
createDirs $MAEDIR $BINDIR $INFODIR $DUPDIR $LOGDIR

# TODO: crear archivo .conf
# TODO: Limpiar variables
