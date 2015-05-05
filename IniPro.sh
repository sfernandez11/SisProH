#!/bin/bash

# Script a cargo de la inicializacion de variables de ambiente
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$. IniPro.sh 
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh

logINFO "Comienzo de ejecucion de IniPro"

if ! environmentIsEmpty ; then 
	logINFO "Ambiente ya inicializado. Si quiere reiniciar termine su sesion e ingrese nuevamente"
	return 1
fi

GRUPO=$(getRootDir)
CONFDIR=$GRUPO/conf
CONFFILE=$CONFDIR/InsPro.conf

if rootDirExists; then
	logINFO "Directorio raiz del sistema detectado: $GRUPO"
else
	logERROR "No se encontro el Directorio raiz	del sistema"
	return 1
fi

if confDirExists; then
	logINFO "Directorio de configuracion del sistema detectado: $CONFDIR"
	showDirectory $CONFDIR
else
	logERROR "No se encontro el Directorio de configuracion	del sistema"
	return 1
fi

if confFileExists; then
	logINFO "Archivo de configuracion detectado en $CONFFILE"
else
	logERROR "No existe el archivo de configuracion InsPro.conf en $CONFDIR"	
	return 1
fi

logINFO "Leyendo archivo de configuracion..."
if readVariables; then
	logINFO "Archivo de configuracion procesado correctamente"
else
	logERROR "Archivo de configuracion invalido, reinstale el sistema e intente nuevamente"	
	return 1
fi

logINFO "Exportando variables de ambiente..."

exportEnvVar

logINFO "Verificando la existencia de ejecutables..."
if checkBinFilesExists; then
	logINFO "Archivos ejecutables detectados"
else
	logERROR "No existen los comandos ejecutables requeridos en $BINDIR"
	return 1
fi

logINFO "Verificando la existencia de archivos maestros..."
if checkMaeFilesExists; then
	logINFO "Archivos maestros detectados"
else
	logERROR "No existen los archivos maestros requeridos en $MAEDIR"
	return 1
fi

logINFO "Verificando la existencia de tablas maestras..."
if checkTableFilesExists; then
	logINFO "Tablas maestras detectadas"
else
	logERROR "No existen las tablas maestras requeridas en $MAEDIR/tab"
	return 1
fi

logINFO "Verificando permisos de ejecucion..."
if setPermissions; then
	logINFO "Permisos de ejecucion correctos"
else	
	logERROR "No se pudo setear correctamente los permisos de ejecucion"
	return 1
fi

logINFO "Estado del Sistema: INICIALIZADO"

askStartDeamon

logINFO "Fin de ejecucion del IniPro"