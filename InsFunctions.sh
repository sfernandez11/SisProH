# Funciones usadas para la instalacion (InsPro)
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
function divide(){
    echo $((($1 + $2/2) / $2))
}

function freeSpace(){
    local free_space_bytes
    #local free_space_mb
    free_space_bytes=`df $1 | tail -n 1 | tr -s ' ' | cut -d' ' -f 4`
    #let free_space_gb="$free_space_bytes/1024/1024"
    #free_space_mb=`echo $free_space_bytes\/1024 | bc -l`
  
    echo $(divide $free_space_bytes 1024)
}

function logInfo(){
    echo InsPro $1
}

function logError(){
    echo InsPro $1 ERR
}

function setVariable(){
    local prevval
    local vaux
    eval prevval=\$$1
    local myresult=$prevval
    read -p "Defina $2 ($prevval):" vaux

    if [ -n "$vaux" ]
    then
      logInfo "$1 cambiado a $vaux"
      myresult=$vaux
    fi
    
    if [[ "$1" ]];
    then
      eval $1="'$myresult'"
    fi
}

function setDir(){
    setVariable $1 "el directorio para $2"
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
        logInfo "directorio $var ya existe"
        continue
      fi
      if createDir "$var";
      then
        logInfo "Ok directorio $var creado"
      else
        logError "Error nro $? al crear directorio $var"
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
    return 0
  fi
  return 1
}

function isInteger(){
  case $1 in
    ''|*[!0-9]*) return 1;;
    *) return 0 ;;
  esac
}

function isDirSimple(){
    if echo $1 | grep -E '^([[:alnum:]]+[_.-]*[[:alnum:]]*)+$' > /dev/null;
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
