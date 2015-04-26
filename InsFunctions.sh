#!/bin/bash
# Funciones usadas para la instalacion (InsPro)
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------

function divide(){
  echo $((($1 + $2/2) / $2))
}

function freeSpace(){
  local free_space_bytes
  free_space_bytes=`df $1 | tail -n 1 | tr -s ' ' | cut -d' ' -f 4`

  echo $(divide $free_space_bytes 1024)
}

function logInfo(){
  echo InsPro $1
  #echo $1
  #echo
}

function logError(){
  logInfo "$1 ERR"
}

function setVariable(){
  local prevval
  local vaux
  eval prevval=\$$1
  local myresult=$prevval
  read -p "Defina $2 ($3$prevval):" vaux

  while [ -n "$vaux" ]
  do
    #logInfo "$1 cambiado a $vaux"
    if isValid $1 $vaux;
    then
      #myresult=$vaux
      myresult=`echo "$vaux" | sed 's:^/\{0,1\}\(.*\)$:\1:'`
      vaux=""
    else
      echo valor invalido, reingrese.
      read -p "Defina $2 ($3$prevval):" vaux
    fi
  done

  eval $1="'$myresult'"
}

function setDir(){
  # Supuesto: si ya existe el directorio
  # asumo que esta instalado ese componente
  # y no pido que el usuario lo redefina
  local prevval
  eval prevval=\$$1
  if [ ! -d "$GRUPO/$prevval" ];
  then
    setVariable $1 "el directorio para $2" "$GRUPO/"
  fi
}

function createDir() {
  # creo un directorio
  if mkdir $1 2>/dev/null;
  then
    return 0
  fi
  return 1
}

function createDirs(){
  # creo una lista de directorios
  if [ ! -d "$GRUPO" ]; then
    # controlo que exista el directorio $GRUPO
    if createDir "$GRUPO";
    then
      logInfo "Directorio $GRUPO creado "
    else
      logError "Error al crear el directorio base $GRUPO."
      exit 1
    fi
  fi
  for var in "$@"
  do
    local curr="$GRUPO/$var"
    if [ -d "$curr" ]
    then
      logInfo "directorio $curr ya existe"
      continue
    fi
    if createDirWithSubdir "$var";
    then
      logInfo "Ok directorio $var creado"
      #else
      #  logError "Error nro $? al crear directorio $var"
    fi
  done
}

function getPerlVersion(){
  if perl -v < /dev/null &>/dev/null;
  then
    local perlinfo=`perl -v | grep '.' | head -n 1`
    local version=`echo $perlinfo | sed 's/.*v\([0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}\).*/\1/'`
    echo $version
    return 0
  else
    return 1
  fi
}

function noCompatiblePerlVersion(){
  if PERL_VERSION=$(getPerlVersion);
  then
    logInfo "Perl version $PERL_VERSION instalada"
    version=`echo $PERL_VERSION | sed 's/\([0-9]\{1,2\}\)\..*/\1/'`
    if [[ version -ge 5 ]]
    then
      logInfo "Version de perl $version instalada es compatible con el sistema"
      return 1
    fi
  fi
  return 0
}

function isInteger(){
  case $1 in
    ''|*[!0-9]*) return 1;;
    *) return 0 ;;
  esac
}

function isDirSimple(){
  if echo $1 | grep -E '^/?([[:alnum:]]+[_.-]*[[:alnum:]]*)+/?$' > /dev/null;
  then
    #echo "yes"
    return 0
  else
    #echo "no"
    return 1
  fi
}

function isDirPath(){
  if echo $1 | grep -E '^/([^[:punct:]]+/?)+$' > /dev/null;
  then
    #echo "yes"
    return 0
  else
    #echo "no"
    return 1
  fi
}

function isValid(){
	case $1 in
	  DUPDIR)
	    if isDirSimple $2;
	    then
	      if [[ $2 == conf ]] || [[ $2 == pruebas ]]
	      then
	        logError "\"$2\" No puede ser elegido como nombre."
	        return 1
	      fi
	      return 0
	    fi
	    logError "\"$2\" No es un directorio simple."
	    return 1
	    ;;
	  *DIR)
	    if isDirSimple $2;
	    #if $(isDirSimple $2)  || $(isDirPath $2)
	    then
	      if [[ $2 == conf ]] || [[ $2 == pruebas ]]
	      then
	        logError "\"$2\" No puede ser elegido como nombre."
	        return 1
	      fi
	      return 0
	    else
	      if isDirPath $2;
	      then
	        return 0
	      fi
	    fi
	    logError "\"$2\" es un nombre de directorio invalido."
	    return 1
	    ;;
	  *SIZE)
	    if isInteger $2;
	    then
	      return 0
	    fi
	    logError "\"$2\" No es un numero entero."
	    return 1
	esac
}

function createDirWithSubdir(){
  # creo una lista de directorios que contienen subdirectorios
  # TODO: variables locales
  local BASE=$GRUPO
  local FOLDERS=$1

  local NEWBASE=$BASE
  for c in `echo $FOLDERS | tr "/" " "`; do
    NEWBASE="$NEWBASE/$c"
    if [ -d "$NEWBASE" ]
    then
      #logInfo "directorio $var ya existe"
      continue
    fi
    if ! $(createDir "$NEWBASE")
    then
      #logInfo "Directorio $NEWBASE creado."
    #else
      logError "No se pudo crear directorio $NEWBASE"
      return 1
    fi
  done
  return 0

}

function showStatus(){
  echo
  echo
  logInfo "--- TP SO7508 Primer Cuatrimestre 2015. Tema H Copyright © Grupo 02 ---"
  echo
  logInfo "Directorio de Configuracion: $GRUPO/$CONFDIR"
  showDirContent $CONFDIR
  logInfo "Directorio de Ejecutables: $GRUPO/$BINDIR"
  showDirContent $BINDIR
  logInfo "Directorio de Maestros y Tablas: $GRUPO/$MAEDIR"
  showDirContent $MAEDIR
  logInfo "Directorio de recepción de documentos p/ protocolización: $GRUPO/$NOVEDIR"
  logInfo "Espacio mínimo libre para arribos: $DATASIZE Mb"
  logInfo "Directorio de Archivos Aceptados: $GRUPO/$ACEPDIR"
  logInfo "Directorio de Archivos Rechazados: $GRUPO/$RECHDIR"
  logInfo "Directorio de Archivos Protocolizados: $GRUPO/$PROCDIR"
  logInfo "Directorio para informes y estadísticas: $GRUPO/$INFODIR"
  logInfo "Nombre para el repositorio de duplicados: $GRUPO/$DUPDIR"
  logInfo "Directorio para Archivos de Log: $GRUPO/$LOGDIR"
  showDirContent $LOGDIR
  logInfo "Tamaño máximo para archivos de log: $LOGSIZE Kb"
  logInfo "Estado de la instalación: LISTA"
    
}

function showDirContent(){
  if [ -d "$GRUPO/$1" ]
  then
    if [ "$(ls -A $GRUPO/$1)" ]
    then
      logInfo "Contenido:"
      for file in $GRUPO/$1/* ;
      do
         if [ -f "$file" ]
         then
           logInfo "${file##*/}"
         fi
      done
    else
    logInfo "Directorio vacio."
    fi
  else
    logInfo "Directorio no existe."
  fi
}

