#!/bin/bash

# Script a cargo de la inicializacion de variables de ambiente
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$. IniPro.sh 
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh

if ! checkAmbiente; then 
	exit 1
fi

GRUPO=$PWD/grupo02

if confFileNotFound; then
	echo "No existe el archivo de configuracion"
	exit 1
fi

CONFDIR=$GRUPO/conf
CONFFILE=$CONFDIR/InsPro.conf

echo "Exportando variables de ambiente..."

echo "Directorio raiz del sistema: "$GRUPO
echo "Directorio de configuracion: "$CONFDIR

if [ "$BINDIR" == "" ]; then
	BINDIR=`grep "BINDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio de Ejecutables: BINDIR "$BINDIR
	#TODO Listar files en BINDIR
fi

if [ "$MAEDIR" == "" ]; then
	MAEDIR=`grep "MAEDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio de Maestros y Tablas: MAEDIR "$MAEDIR
	#TODO Listar files in MAEDIR
fi

if [ "$NOVEDIR" == "" ]; then
	NOVEDIR=`grep "NOVEDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio de recepción de documentos para protocolización: NOVEDIR "$NOVEDIR
fi

if [ "$DATASIZE" == "" ]; then
	DATASIZE=`grep "DATASIZE" $CONFFILE | cut -s -f2 -d'='`
	echo "DATASIZE es: "$DATASIZE
fi

if [ "$ACEPDIR" == "" ]; then
	ACEPDIR=`grep "ACEPDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio de Archivos Aceptados: ACEPDIR "$ACEPDIR
fi

if [ "$RECHDIR" == "" ]; then
	RECHDIR=`grep "RECHDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio de Archivos Rechazados: RECHDIR "$RECHDIR
fi

if [ "$PROCDIR" == "" ]; then
	PROCDIR=`grep "PROCDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio de Archivos Protocolizados: PROCDIR "$PROCDIR
fi

if [ "$INFODIR" == "" ]; then
	INFODIR=`grep "INFODIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio para informes y estadísticas: INFODIR "$INFODIR
fi

if [ "$DUPDIR" == "" ]; then
	DUPDIR=`grep "DUPDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Nombre para el repositorio de duplicados: DUPDIR "$DUPDIR
fi

if [ "$LOGDIR" == "" ]; then
	LOGDIR=`grep "LOGDIR" $CONFFILE | cut -s -f2 -d'='`
	echo "Directorio para Archivos de Log: LOGDIR "$LOGDIR
fi

if [ "$LOGSIZE" == "" ]; then
	LOGSIZE=`grep "LOGSIZE" $CONFFILE | cut -s -f2 -d'='`
	echo "LOGSIZE: "$LOGSIZE
fi

export GRUPO
export MAEDIR
export NOVEDIR
export DATASIZE
export ACEPDIR
export RECHDIR
export PROCDIR
export INFODIR
export DUPDIR
export LOGDIR
export LOGSIZE

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

echo "Asignando permisos de ejecucion..."
checkPerm

echo "Estado del Sistema: INICIALIZADO"

askStartDeamon

#Cerrar archivo de log y terminar proceso
