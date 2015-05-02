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
CONFDIR=$GRUPO/conf

# TODO: CONFDIR ya deberia existir
createDirs $CONFDIR

# TODO: verificar si ya esta instalado y cosas que faltan instalar
if [ -f $CONFDIR/InsPro.conf ]
then
  echo "Ya esta instalado."
  readConf
  verifyDirsExisting
  initialize
  if installComplete;
  then
    setEnviroment
    showStatus
    logInfo "Estado de la instalación: COMPLETA"
    exit 0
  fi
  echo "Verificando si esta completo ..."
fi


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

initialize

until [ "$CONFIRM_INSTALL" = "SI" ]
do
  if [ -n "$CONFIRM_INSTALL" ]
  then
    # limpio la pantalla
    printf "\033c"
    logInfo "Instalacion reiniciada .."
  fi
  # pido al usuario que ingrese los valores de las variables
  askVariables
  setEnviroment

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
  askInstall

done

# creacion de directorios
createDirs $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR
createDirs $MAEDIR $BINDIR $INFODIR $DUPDIR $LOGDIR

writeConf
installBinaries
installTabs
unsetVariables

