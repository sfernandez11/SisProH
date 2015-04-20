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

# valores por defecto de las variables de ambiente
CONFDIR=$GRUPO/conf
MAEDIR=$GRUPO/mae
NOVEDIR=$GRUPO/novedades
ACEPDIR=$GRUPO/a_protocolarizar
RECHDIR=$GRUPO/rechazados
PROCDIR=$GRUPO/protocolizados
INFODIR=$GRUPO/informes
DUPDIR=$GRUPO/dup
LOGDIR=$GRUPO/log
BINDIR=$GRUPO/bin
DATASIZE=100
LOGSIZE=400

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
setVariable DATASIZE "espacio mínimo libre para el arribo de estas novedades en Mbytes"

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
# se cumplieron todas las validaciones empiezo a crear las cosas

# creacion de directorios
createDirs $GRUPO $NOVEDIR $ACEPDIR $RECHDIR $PROCDIR
createDirs $MAEDIR $BINDIR $INFODIR $DUPDIR $LOGDIR
