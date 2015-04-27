#!/bin/bash

# Script a cargo de la inicializacion de variables de ambiente
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$. IniPro.sh 
#------------------------------------------------------------------------------------------------------------

#ambiente ya inicializado, si quiere reiniciar termine su sesión e ingrese nuevamente (Grabar en el log y terminar la ejecución)

#Es indispensable contar con el archivo de configuración, 

#los comandos, 

#archivos maestros 

#y tablas con los permisos adecuados.


#Continúa con la asignación de valor a un conjunto de variables de ambiente 

GRUPO=$PWD/grupo02
CONFDIR=$GRUPO/conf
CONFFILE=$CONFDIR/InsPro.conf

echo "Exportando variables de ambiente..."

NOVEDIR=`grep "NOVEDIR" $CONFFILE | cut -s -f2 -d'='`

echo "Nove dir es: "$NOVEDIR
export GRUPO="$PWD/grupo02"
echo "Grupo: "$GRUPO
export $NOVEDIR #="$GRUPO/novedades"
echo "Novedir: "$NOVEDIR
export RECHDIR="$GRUPO/rechazados"
echo "Rechdir: "$RECHDIR
export BINDIR="$GRUPO/bin"
echo "Bindir: "$BINDIR
export MAEDIR="$GRUPO/mae"
echo "Maedir: "$MAEDIR
export REPODIR="$GRUPO/informes"
echo "Repodri: "$REPODIR
export PATH=$PATH:$BINDIR
echo "PATH: "$PATH

echo "Fin de exportar variables de ambiente"


#Directorio de Configuración: CONFDIR (mostrar path y listar archivos)
#Directorio de Ejecutables: BINDIR (mostrar path y listar archivos)
#Directorio de Maestros y Tablas: MAEDIR (mostrar path y listar archivos)
#Directorio de recepción de documentos para protocolización: NOVEDIR
#Directorio de Archivos Aceptados: ACEPDIR
#Directorio de Archivos Rechazados: RECHDIR
#Directorio de Archivos Protocolizados: PROCDIR
#Directorio para informes y estadísticas: INFODIR
#Nombre para el repositorio de duplicados: DUPDIR
#Directorio para Archivos de Log: LOGDIR (mostrar path y listar archivos)
#Estado del Sistema: INICIALIZADO


#Ofrece arrancar automáticamente el comando de recepción de documentos para protocolización.

#“Desea efectuar la activación de RecPro?” Si – No

#6.1.
#Si el usuario no desea arrancar el demonio RecPro, entonces explicar cómo hacerlo con el
#comando Start
#6.2.
#Si el usuario desea arrancar el demonio RecPro, activarlo (SOLO SI NO EXISTE OTRO
#RecPro CORRIENDO) y explicar cómo detenerlo usando el comando Stop.
#6.3.
#Mostrar mensaje y grabar en el log
#RecPro corriendo bajo el no.: <Process Id de RecPro>

#Cerrar archivo de log y terminar proceso
