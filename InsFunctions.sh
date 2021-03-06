#!/bin/bash
# Funciones usadas para la instalacion (InsPro)
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------

source commonFunctions.sh

declare -a variables
declare -a messages
declare -a installed
declare -a values

function divide(){
  echo $((($1 + $2/2) / $2))
}

function freeSpace(){
  local free_space_bytes
  free_space_bytes=`df $1 | tail -n 1 | tr -s ' ' | cut -d' ' -f 4`

  echo $(divide $free_space_bytes 1024)
}

function log(){
	if [ -f glog.sh ]
  then
    if [ ! -x glog.sh ]
    then
      chmod +x glog.sh
    fi
		./glog.sh "InsPro" "$1" "$2" #1= log message, 2= log level
	fi
}

function logInfo(){
	echo "[INFO] $1" 
	log "$1" "INFO"
}	
function logError(){
	echo "[ERROR] $1"
	log "$1" "ERR"
}

function logWar(){
	echo "[WARNING] $1" 
	log "$1" "WAR"
}


function setVariable(){
  local vaux
  local index=$(getIndex variables "$1")  
  read -p "Defina $2 (${values[$index]}):" vaux

  while [ -n "$vaux" ]
  do
    if isValid $1 $vaux;
    then
      if isInteger $vaux;
      then
        values[$index]=$vaux
      else
        vaux=`echo $vaux | sed "s>^$GRUPO>>"`
        vaux=`echo "$vaux" | sed 's:^/\{0,1\}\(.*\)$:\1:'`
        values[$index]="$GRUPO/$vaux"
      fi
      vaux=""
    else
      echo valor invalido, reingrese.
      read -p "Defina $2 (${values[$index]}):" vaux
    fi
  done
  eval $1="${values[$index]}"
}

function setDir(){
  # Supuesto: si ya existe el directorio
  # asumo que esta instalado ese componente
  # y no pido que el usuario lo redefina
  local index=$(getIndex variables "$1")
  if [ ! -d "${values[$index]}" ];
  then
    setVariable $1 "el directorio para $2"
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

  for var in "$@"
  do
    if [ -d "$var" ]
    then
      #logInfo "directorio $var ya existe"
      continue
    fi
    if createDirWithSubdir "$var";
    then
      logInfo "Directorio $var creado"
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
      return 1
    fi
  fi
  return 0
}

function isDirSimple(){
  if echo $1 | grep -E '^/?([[:alnum:]]+[_.-]*[[:alnum:]]*)+/?$' > /dev/null;
  then
    if isInteger $1;
    then
      return 1
    fi
    return 0
  fi  #else
  return 1
  #fi
}

function isDirPath(){
  if echo $1 | grep -E '^/([^[:punct:]]+/?)+$' > /dev/null;
  then
    return 0
  else
    return 1
  fi
}

function isValid(){
	case $1 in
	  DUPDIR)
	    if isDirSimple $2;
	    then
	      if [[ $2 =~ ^/?conf ]] || [[ $2 =~ ^/?pruebas ]]
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
	    then
        if [[ $2 =~ ^/?conf ]] || [[ $2 =~ ^/?pruebas ]]
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
  local BASE=$GRUPO
  local FOLDERS=`echo $1 | sed "s>^$GRUPO>>"`

  local NEWBASE=$BASE
  for c in `echo $FOLDERS | tr "/" " "`; do
    NEWBASE="$NEWBASE/$c"
    if [ -d "$NEWBASE" ]
    then
      continue
    fi
    if ! $(createDir "$NEWBASE")
    then
      echo "No se pudo crear directorio $NEWBASE"
      return 1
    fi
  done
  return 0

}

function showStatus(){
  local index
  echo
  echo
  logInfo "--- TP SO7508 Primer Cuatrimestre 2015. Tema H Copyright © Grupo 02 ---"
  echo
  logInfo "Directorio de Configuracion: $CONFDIR"
  showDirContent $CONFDIR
  logInfo "Directorio de Ejecutables: $BINDIR"
  showDirContent $BINDIR
  logInfo "Directorio de Maestros y Tablas: $MAEDIR"
  showDirContent $MAEDIR
  logInfo "Directorio de recepción de documentos p/ protocolización: $NOVEDIR"
  logInfo "Espacio mínimo libre para arribos: $DATASIZE Mb"
  logInfo "Directorio de Archivos Aceptados: $ACEPDIR"
  logInfo "Directorio de Archivos Rechazados: $RECHDIR"
  logInfo "Directorio de Archivos Protocolizados: $PROCDIR"
  logInfo "Directorio para informes y estadísticas: $INFODIR"
  logInfo "Nombre para el repositorio de duplicados: $DUPDIR"
  logInfo "Directorio para Archivos de Log: $LOGDIR"
  showDirContent $LOGDIR
  logInfo "Tamaño máximo para archivos de log: $LOGSIZE Kb"
    
}

function getArraySize(){
  eval len=\( \${#${1}[@]} \)
  echo $len
}


function getIndex(){

  ref="$1"[i]

  count=$(getArraySize $1)

  for (( i = 0; i < $count; i++ )); do

    if [ "${!ref}" = "$2" ]; then
      echo $i
      return 0
    fi
  done
  return 1
}

function configureVar(){
  local index=$(getIndex variables $1)
  if [ "${installed[$index]}" = false -o "${installed[$index]}" = "" ];
  then
    local value=`[[ "$1" == *DIR ]] && echo $GRUPO/$2 || echo $2`
    values[$index]=$value
    installed[$index]=false
  fi
  messages[$index]=$3
}

function initialize(){
  if [ ${#variables[@]} -eq 0 ];
  then
    variables=(MAEDIR NOVEDIR ACEPDIR RECHDIR PROCDIR INFODIR DUPDIR LOGDIR BINDIR DATASIZE LOGSIZE SECUENCIA)
  fi

  # valores por defecto de las variables de ambiente
  configureVar MAEDIR "mae" "maestros y tablas"
  configureVar NOVEDIR "novedades" "recepción de documentos para protocolización"
  configureVar ACEPDIR "a_protocolarizar" "grabación de las Novedades aceptadas"
  configureVar RECHDIR "rechazados" "grabación de Archivos rechazados"
  configureVar PROCDIR "protocolizados" "grabación de los documentos protocolizados"
  configureVar INFODIR "informes" "grabación de los informes de salida"
  configureVar INFODIR "informes" "grabación de los informes de salida"
  configureVar INFODIR "informes" "grabación de los informes de salida"
  configureVar DUPDIR "dup" "repositorio de archivos duplicados"
  configureVar LOGDIR "log" "logs"
  configureVar BINDIR "bin" "instalación de los ejecutables"
  configureVar DATASIZE "100" "espacio mínimo libre para el arribo de las novedades en Mbytes"
  configureVar LOGSIZE "400" "tamaño máximo para cada archivo de log en Kbytes"
  configureVar SECUENCIA "1"

}

function askVariables(){
  local varLength=${#variables[@]}

  for (( i = 0; i < ${varLength}; i++ ));
  do
    if [ "${installed[$i]}" = false ];
    then
    	case ${variables[$i]} in
        *DIR)
          setDir "${variables[$i]}" "${messages[$i]}"
          ;;
        *SIZE)
          setVariable "${variables[$i]}" "${messages[$i]}"
          ;;
      esac
    fi
  done

}

function writeConf(){
  logInfo "Actualizando la configuración del sistema . . ."
  local file="$CONFDIR/InsPro.conf"
  local sep='='
  local now=$(date +"%m-%d-%Y %H:%M:%S")
  local currentUser=$USER
  local varLength=${#variables[@]}
  echo $sep > $file
  for (( i = 0; i < ${varLength}; i++ ));
  do
    echo "${variables[$i]}$sep${values[$i]}$sep$currentUser$sep$now" >> $file
  done
}

function readConf(){
  local file="$CONFDIR/InsPro.conf"
  local sep=$(head -n 1 "$file")
  
  local i=0
  while read line
  do
    variables[$i]=$(echo $line | cut -f1 -d"$sep")
    values[$i]=$(echo $line | cut -f2 -d"$sep")
    if [[ ${variables[$i]} == *DIR ]];
    then
      # los directorios se chequean despues
      installed[$i]=false
    else
      # los valores numericos
      installed[$i]=true
    fi
    (( i++ ))
  done < <(grep -v ^.$ $file)
}

function installBinaries(){
  logInfo "Instalando Programas y Funciones"
  cp -a *.sh $BINDIR
  cp -a RecPro/*.sh $BINDIR
  cp -a ProPro/*.sh $BINDIR
  cp -a InfPro/*.pm $BINDIR
  cp -a InfPro/*.pl $BINDIR
  
  chmod +x $BINDIR/*
}

function installTabs(){
  logInfo "Instalando Archivos Maestros y Tablas"
  cp -a Datos/*.mae $MAEDIR
  cp -ar Datos/*.tab "$MAEDIR/tab"
  #cp -a pruebas/* $NOVEDIR
}

function unsetVariables(){
  for (( i = 0; i < ${#variables[@]}; i++ ));
  do
    eval "unset ${variables[$i]}"
  done
}

function setEnviroment(){
  for (( i = 0; i < ${#variables[@]}; i++ ));
  do
    eval ${variables[$i]}=${values[$i]}
    export ${variables[$i]}
  done

}

function initializeEnviroment(){
  readConf
  setEnviroment
}

function verifyDirsExisting(){
  for (( i = 0; i < ${#variables[@]}; i++ ));
  do
    if [[ ${variables[$i]} == *DIR ]];
    then
      if [ ! -d "${values[$i]}" ];
      then
        installed[$i]=false
      else
        installed[$i]=true
      fi
    else
      installed[$i]=true
    fi
  done
}

function showDirContent(){
  if [ -d "$1" ]
  then
    if [ "$(ls -A $1)" ]
    then
      #logInfo "Contenido:"
      local var="Contenido: "
      for file in $1/* ;
      do
        if [ ${#var} -ge 70 ]
        then
          logInfo "$var"
          var=""
          #logInfo "${file##*/}"
        fi
        var=$var" ${file##*/}"
      done
      if [ ${#var} -ge 1 ]
      then
        logInfo "$var"
      fi
    else
    logInfo "Directorio vacio."
    fi
  else
    logInfo "Directorio no existe."
  fi
}

function askInstall(){
echo "$1 ( 1 = Si – 2 = No )"

	select yn in "Si" "No"; do
	    case $yn in
	        Si ) CONFIRM_INSTALL="SI"; break;;
	        No ) CONFIRM_INSTALL="NO"; break;;
		      * ) echo "Por favor, seleccione una opcion";;
	    esac
	done
}

function installComplete() {
  if thereAreMissingComponents;
  then
    return 1
  fi
  if [ $(binariesNotInstalled) -gt 0 ];
  then
    return 1
  fi
  if [ $(maesNotInstalled) -gt 0 ];
  then
    return 1
  fi

  return 0
}

function filesMissing(){
  local from=$1
  local extension=$2
  local to=$3
  diff -q $from $to | grep $from:.*\.$extension | wc -l
}

function binariesNotInstalled(){
  local binBase=$(filesMissing $PWD "sh" "$BINDIR")
  local binRecPro=$(filesMissing "$PWD/RecPro" "sh" "$BINDIR")
  local binProPro=$(filesMissing "$PWD/ProPro" "sh" "$BINDIR")
  local binInfPro=$(filesMissing "$PWD/InfPro" "pl" "$BINDIR")
  local auxInfPro=$(filesMissing "$PWD/InfPro" "pm" "$BINDIR")
  #echo "Faltan $binBase de pwd, $binRecPro de RecPro y $binProPro de ProPro"
  let total=$binBase+$binRecPro+$binProPro+$binInfPro+$auxInfPro
  #echo "En total faltan $total binarios"
  echo $total
}

function maesNotInstalled(){
  local maeBase=$(filesMissing "$PWD/Datos" "mae" $MAEDIR)
  local maeTab=$(filesMissing "$PWD/Datos" "tab" $MAEDIR/tab)
  #echo "Faltan $maeBase de maebase, $maeTab de maetab"
  let total=$maeBase+$maeTab
  #echo "En total faltan $total maes"
  echo $total
}

function componentsMissing(){
  local comp
  for (( i = 0; i < ${#variables[@]}; i++ ));
  do
    if [ "${installed[$i]}" = false ];
    then
      comp=$comp" ${variables[$i]}"
    fi
  done
  echo "Componentes faltantes: $comp "
}

function thereAreMissingComponents(){
  for i in "${installed[@]}"
  do
    if [ $i = false ]
    then
      return 0
    fi
  done
  return 1
}

function showStatusNoMissing(){
  local index
  echo
  echo
  logInfo "--- TP SO7508 Primer Cuatrimestre 2015. Tema H Copyright © Grupo 02 ---"
  echo
  logInfo "Directorio de Configuracion: $CONFDIR"
  showDirContent $CONFDIR
  index=$(getIndex variables BINDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio de Ejecutables: $BINDIR"
    showDirContent $BINDIR
  fi
  index=$(getIndex variables MAEDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio de Maestros y Tablas: $MAEDIR"
    showDirContent $MAEDIR
  fi
  index=$(getIndex variables NOVEDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio de recepción de documentos p/ protocolización: $NOVEDIR"
  fi
  logInfo "Espacio mínimo libre para arribos: $DATASIZE Mb"
  index=$(getIndex variables ACEPDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio de Archivos Aceptados: $ACEPDIR"
  fi
  index=$(getIndex variables RECHDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio de Archivos Rechazados: $RECHDIR"
  fi
  index=$(getIndex variables PROCDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio de Archivos Protocolizados: $PROCDIR"
  fi
  index=$(getIndex variables INFODIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio para informes y estadísticas: $INFODIR"
  fi
  index=$(getIndex variables DUPDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Nombre para el repositorio de duplicados: $DUPDIR"
  fi
  index=$(getIndex variables LOGDIR)
  if [ "${installed[$index]}" = true ];
  then
    logInfo "Directorio para Archivos de Log: $LOGDIR"
    showDirContent $LOGDIR
  fi
  logInfo "Tamaño máximo para archivos de log: $LOGSIZE Kb"
    
}
