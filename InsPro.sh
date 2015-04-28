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

declare -a variables
declare -a messages
declare -a installed
declare -a values


initialize

GRUPO=$PWD/grupo02
CONFDIR=conf

# TODO: verificar si ya esta instalado y cosas que faltan instalar
if [ -f $GRUPO/$CONFDIR/InsPro.conf ]
then
  echo "Ya esta instalado."
  exit 0

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
  askVariables

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

writeConf

# TODO: crear archivo .conf
# TODO: Limpiar variables
