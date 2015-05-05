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
LOGSIZE=400
export LOGSIZE
export GRUPO
export CONFDIR

# TODO: CONFDIR ya deberia existir
if mkdir "$PWD/grupo02" 2>/dev/null ;
then
if ! createDirWithSubdir "$CONFDIR";
then
  echo "Erro al crear $CONFDIR"
  exit 1
fi
else
  echo "Erro al crear $PWD/grupo02"
  exit 1
fi



# TODO: verificar si ya esta instalado y cosas que faltan instalar
if [ -f $CONFDIR/InsPro.conf ]
then
  echo "Ya esta instalado."
  readConf
  verifyDirsExisting
  initialize
  setEnviroment
  if installComplete;
  then
    showStatus
    logInfo "Estado de la instalación: COMPLETA"
    logInfo "Proceso de Instalación Cancelado"
    exit 0
  fi
  # al llegar aca la instalacion esta incompleta
  
else
  initialize
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
  logInfo "Estado de la instalación: LISTA"
  askInstall "Inicia la instalación?"

done

if [ "$CONFIRM_INSTALL" = "SI" ]
then
  askInstall "Iniciando Instalación. Esta Ud. seguro?"
  if [ "$CONFIRM_INSTALL" = "NO" ]
  then
    exit 0
  fi
fi

# creacion de directorios
logInfo "Creando Estructuras de directorio . . ."
createDirs $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR
createDirs $MAEDIR $BINDIR $INFODIR $DUPDIR $LOGDIR
createDirs "$MAEDIR/tab" "$MAEDIR/tab/ant" "$PROCDIR/proc"

writeConf
installBinaries
installTabs
unsetVariables

logInfo "Instalación CONCLUIDA"
