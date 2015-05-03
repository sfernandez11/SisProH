function environmentNotEmpty(){
	if [ "$BINDIR" == "" ]; then	
		return 1
	fi

	if [ "$MAEDIR" == "" ]; then	
		return 1
	fi

	if [ "$NOVEDIR" == "" ]; then	
		return 1
	fi

	if [ "$DATASIZE" == "" ]; then	
		return 1
	fi

	if [ "$ACEPDIR" == "" ]; then	
		return 1
	fi

	if [ "$RECHDIR" == "" ]; then	
		return 1
	fi

	if [ "$PROCDIR" == "" ]; then	
		return 1
	fi

	if [ "$INFODIR" == "" ]; then	
		return 1
	fi

	if [ "$DUPDIR" == "" ]; then	
		return 1
	fi

	if [ "$LOGDIR" == "" ]; then	
		return 1
	fi

	if [ "$LOGSIZE" == "" ]; then	
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
