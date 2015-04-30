#!/bin/bash

# Script a cargo de la inicializacion de variables de ambiente
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$. IniPro.sh 
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh
source InsFunctions.sh

if ! checkAmbiente; then 
	echo "Ambiente ya inicializado"
	return 1
fi

GRUPO="$(dirname "$PWD")"

if confFileNotFound; then
	echo "No existe el archivo de configuracion"
	return 1
fi

CONFDIR=$GRUPO/conf
CONFFILE=$CONFDIR/InsPro.conf

echo "Exportando variables de ambiente..."

echo "Directorio raiz del sistema: "$GRUPO
echo "Directorio de configuracion: "$CONFDIR

initializeEnviroment

export PATH=$PATH:$BINDIR
echo "Se agrego $BINDIR al PATH. PATH= "$PATH

echo "Fin de exportar variables de ambiente"

echo "Verificando la existencia de ejecutables..."
if [ ! checkBinFiles ]; then
	echo "No existen los comandos ejecutables"
	return 1
fi

echo "Verificando la existencia de archivos maestros..."
if [ ! checkMaeFiles ]; then
	echo "No existen los archivos maestros"
	return 1
fi

echo "Verificando la existencia de tablas maestras..."
if [ ! checkTableFiles ]; then
	echo "No existen las tablas maestras"
	return 1
fi

echo "Verificando permisos de ejecucion..."
if permissionsMissing;
then
	return 1
fi

echo "Estado del Sistema: INICIALIZADO"

askStartDeamon

#Cerrar archivo de log y terminar proceso
