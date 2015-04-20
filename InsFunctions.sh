# Funciones usadas para la instalacion (InsPro)
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------

function freeSpace(){
    local free_space_bytes
    local free_space_mb
    free_space_bytes=`df $1 | tail -n 1 | tr -s ' ' | cut -d' ' -f 4`
    #let free_space_gb="$free_space_bytes/1024/1024"
    #free_space_mb=`echo $free_space_bytes\/1024 | bc -l`
  
    echo $free_space_bytes
}

function setVariable(){
    local prevval
    local vaux
    eval prevval=\$$1
    local myresult=$prevval
    read -p "Defina $2 ($prevval):" vaux

    if [ -n "$vaux" ]
    then
      echo InfoLog $1 cambiado a $vaux
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
        echo InfoLog directorio "$var" ya existe
        continue
      fi
      if createDir "$var";
      then
        echo InfoLog Ok directorio "$var" creado
      else
        echo ErrorLog $? al crear $1
      fi
    done
}

function getPerlVersion(){
  if perl -v < /dev/null &>/dev/null;
  then
    local perlinfo=`perl -v | grep '.' | head -n 1`
    local version=`echo $perlinfo | sed 's/.*v\([0-9]\{1,2\}\.[0-9]\{1,2\}\.[0-9]\{1,2\}\) .*/\1/'`
    echo $version
    return 0
  else
    return 1
  fi
}

function noCompatiblePerlVersion(){
  if PERL_VERSION=$(getPerlVersion);
  then
    echo InfoLog Tenemos version de perl $PERL_VERSION
    version=`echo $PERL_VERSION | sed 's/\([0-9]\{1,2\}\)\..*/\1/'`
    if [ $version -ge 5 ]
    then
      echo InfoLog Ok version $version es compatible
      return 1
    fi
    return 0
  fi
  return 1
  
}
