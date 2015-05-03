function environmentNotEmpty(){
	if [ "$BINDIR" == "" ]; then
		logWARNING "La variable BINDIR no se encuentra seteada"
		return 1
	fi

	if [ "$MAEDIR" == "" ]; then
		logWARNING "La variable MAEDIR no se encuentra seteada"
		return 1
	fi

	if [ "$NOVEDIR" == "" ]; then
		logWARNING "La variable NOVEDIR ya no se encuentra seteada"
		return 1
	fi

	if [ "$DATASIZE" == "" ]; then
		logWARNING "La variable DATASIZE ya cno se encuentra seteada"
		return 1
	fi

	if [ "$ACEPDIR" == "" ]; then
		logWARNING "La variable ACEPDIR ya no se encuentra seteada"
		return 1
	fi

	if [ "$RECHDIR" == "" ]; then
		logWARNING "La variable RECHDIR no se encuentra seteada"
		return 1
	fi

	if [ "$PROCDIR" == "" ]; then
		logWARNING "La variable PROCDIR no se encuentra seteada"
		return 1
	fi

	if [ "$INFODIR" == "" ]; then
		logWARNING "La variable INFODIR no se encuentra seteada"
		return 1
	fi

	if [ "$DUPDIR" == "" ]; then
		logWARNING "La variable DUPDIR no se encuentra seteada"
		return 1
	fi

	if [ "$LOGDIR" == "" ]; then
		logWARNING "La variable LOGDIR no se encuentra seteada"
		return 1
	fi

	if [ "$LOGSIZE" == "" ]; then
		logWARNING "La variable LOGSIZE no se encuentra seteada"
		return 1
	fi	

	return 0
}

function getPid(){
    local ppid=`ps aux | grep "\($BINDIR\)\?/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    echo $ppid
}

function isInteger(){
  case $1 in
    ''|*[!0-9]*) return 1;;
    *) return 0 ;;
  esac
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