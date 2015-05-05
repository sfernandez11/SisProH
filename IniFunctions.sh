source commonFunctions.sh


function log(){
	if [ "$VAREXPORTED" == "YES" ];then
		 if [ ! -x glog.sh ]; then
		 	chmod +x glog.sh
			./glog.sh "IniPro" "Seteados permisos de ejecucion para glog.sh" 
		 fi
		./glog.sh "IniPro" "$1" "$2" #1= log message, 2= log level
	fi
}

function logINFO(){
	echo "[INFO] $1" 
	log "$1" "INFO"
}	
function logERROR(){
	echo "[ERROR] $1"
	log "$1" "ERR"
	usetEnvVar
}

function logWARNING(){
	echo "[WARNING] $1" 
	log "$1" "WAR"
}

function checkMaeFilesExists(){	
	if [ ! -f $MAEDIR"/emisores.mae" ]; then
		logWARNING "No existe el maestro de emisores autorizados"
		return 1
	fi
	if [ ! -f $MAEDIR"/normas.mae" ]; then
		logWARNING "No existe el maestro de tipos de normas"
		return 1
	fi
	if [ ! -f $MAEDIR"/gestiones.mae" ]; then
		logWARNING "No existe el maestro de gestiones"
		return 1
	fi
	return 0
}

function confFileExists(){	
	if [ -f $CONFFILE ]; then
		return 0
	fi	
	return 1
}

function confDirExists(){	
	if [ -d $CONFDIR ]; then
		return 0
	fi	
	return 1
}

function rootDirExists(){	
	if [ -d $GRUPO ]; then
		return 0
	fi	
	return 1
}

function getRootDir(){	
	echo "${PWD%grupo02/*}"grupo02
}

function checkBinFilesExists(){
	if [ ! -f $BINDIR"/RecPro.sh" ]; then
		logWARNING "No existe el ejecutable RecPro"
		return 1
	fi	
	if [ ! -f $BINDIR"/ProPro.sh" ]; then
		logWARNING "No existe el ejecutable ProPro"
		return 1
	fi	
	if [ ! -f $BINDIR"/glog.sh" ]; then
		logWARNING "No existe el ejecutable glog"
		return 1
	fi	
	if [ ! -f $BINDIR"/Stop.sh" ]; then
		logWARNING "No existe el ejecutable Stop"
		return 1
	fi	
	if [ ! -f $BINDIR"/Start.sh" ]; then
		logWARNING "No existe el ejecutable Start"
		return 1
	fi	
	return 0
}

function checkTableFilesExists(){
	if [ ! -f $MAEDIR"/tab/nxe.tab" ]; then
		logWARNING "No existe la tabla normas por emisor"
		return 1
	fi
	if [ ! -f $MAEDIR"/tab/axg.tab" ]; then
		logWARNING "No existe la tabla de contadores por año gestion"
		return 1
	fi	
	return 0
}

function setPermissions(){       
    local file
    for file in $BINDIR/*.sh ;
    do
       if [ ! -x "$file" ]; then
         logINFO "No tiene permisos para ejecutar ${file##*/}"
         chmod +x $file
         if [ ! -x "$file" ]; then
         	logWARNING "No se pudo setear permisos para ejecutar ${file##*/}"
         	return 1
         else
         	logINFO "Se setearon permisos para ejecutar ${file##*/} correctamente"
         fi     	
       fi
    done
    return 0
}


function startDeamon(){
	logINFO "Iniciando el demonio RecPro"
	$BINDIR/Start.sh RecPro IniPro
}

function noStartDeamon(){
	logINFO "No se inicio el demonio. Puede arrancarlo manualmente con $ Start.sh RecPro"
}

function askStartDeamon(){
	echo "Desea efectuar la activación del demonio RecPro?"

	select yn in "Si" "No"; do
	    case $yn in
	        Si ) startDeamon; break;;
	        No ) noStartDeamon; break;;
					* ) echo "Por favor, seleccione una opcion valida (1/2)";;
	    esac
	done
}

function environmentIsEmpty(){
	if [ "$BINDIR" != "" ]; then
		logWARNING "La variable BINDIR ya contiene el valor $BINDIR"
		return 1
	fi

	if [ "$MAEDIR" != "" ]; then
		logWARNING "La variable MAEDIR ya contiene el valor $MAEDIR"
		return 1
	fi

	if [ "$NOVEDIR" != "" ]; then
		logWARNING "La variable NOVEDIR ya contiene el valores: $NOVEDIR"
		return 1
	fi

	if [ "$DATASIZE" != "" ]; then
		logWARNING "La variable DATASIZE ya contiene el valor es: $DATASIZE"
		return 1
	fi

	if [ "$ACEPDIR" != "" ]; then
		logWARNING "La variable ACEPDIR ya contiene el valores: $ACEPDIR"
		return 1
	fi

	if [ "$RECHDIR" != "" ]; then
		logWARNING "La variable RECHDIR ya contiene el valor $RECHDIR"
		return 1
	fi

	if [ "$PROCDIR" != "" ]; then
		logWARNING "La variable PROCDIR ya contiene el valor $PROCDIR"
		return 1
	fi

	if [ "$INFODIR" != "" ]; then
		logWARNING "La variable INFODIR ya contiene el valor $INFODIR"
		return 1
	fi

	if [ "$DUPDIR" != "" ]; then
		logWARNING "La variable DUPDIR ya contiene el valor $DUPDIR"
		return 1
	fi

	if [ "$LOGDIR" != "" ]; then
		logWARNING "La variable LOGDIR ya contiene el valor $LOGDIR"
		return 1
	fi

	if [ "$LOGSIZE" != "" ]; then
		logWARNING "La variable LOGSIZE ya contiene el valor $LOGSIZE"
		return 1
	fi	

	return 0
}

function readVariables(){

 	BINDIR=`grep "BINDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$BINDIR" ]; then
 		logWARNING "Directorio de Ejecutables: BINDIR no existe o es invalido "$BINDIR
 		return 1		
 	else
 		logINFO "Se obtuvo el directorio de ejecutables $BINDIR"
 		showDirectory $BINDIR
 	fi
 
 	MAEDIR=`grep "MAEDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$MAEDIR" ]; then
 		logWARNING "Directorio de Maestros y Tablas: MAEDIR no existe o es invalido "$MAEDIR	
 		return 1
 	else
 		logINFO "Se obtuvo el directorio de tablas maestras $MAEDIR"
 		showDirectory $MAEDIR
 	fi
 
 	NOVEDIR=`grep "NOVEDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$NOVEDIR" ]; then
 		logWARNING "Directorio de recepción de documentos para protocolización: NOVEDIR no existe o es invalido "$NOVEDIR
 		return 1
 	else
 		logINFO "Se obtuvo el directorio de recepcion de novedades $NOVEDIR"
 	fi
 
 	DATASIZE=`grep "DATASIZE" $CONFFILE | cut -s -f2 -d'='`

	if ! isInteger "$DATASIZE" ; then
 		logWARNING "DATASIZE no existe o es invalido "$DATASIZE
 		return 1
 	else
 		logINFO "Se obtuvo el valor de DATASIZE $DATASIZE"
 	fi
 
 	ACEPDIR=`grep "ACEPDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$ACEPDIR" ]; then
 		logWARNING "Directorio de Archivos Aceptados: ACEPDIR no existe o es invalido "$ACEPDIR
 		return 1
 	else
 		logINFO "Se obtuvo el directorio de archivos aceptados $ACEPDIR"
 	fi
 
 	RECHDIR=`grep "RECHDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$RECHDIR" ]; then
 		logWARNING "Directorio de Archivos Rechazados: RECHDIR no existe o es invalido "$RECHDIR
 		return 1
 	else	
 		logINFO "Se obtuvo el directorio de archivos rechazados $RECHDIR"
 	fi
 
 	PROCDIR=`grep "PROCDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$PROCDIR" ]; then
 		logWARNING "Directorio de Archivos Protocolizados: PROCDIR no existe o es invalido "$PROCDIR
 		return 1
 	else
 		logINFO "Se obtuvo el directorio de archivos protocolizados $PROCDIR"
 	fi
 
 	INFODIR=`grep "INFODIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$INFODIR" ]; then
 		logWARNING "Directorio para informes y estadísticas: INFODIR no existe o es invalido "$INFODIR
 		return 1
 	else
 		logINFO "Se obtuvo el directorio para informes y estadísticas $INFODIR"
 	fi
 
 	DUPDIR=`grep "DUPDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$DUPDIR" ]; then
 		logWARNING "Nombre para el repositorio de duplicados: DUPDIR no existe o es invalido  "$DUPDIR
 		return 1
 	else
 		logINFO "Se obtuvo el directorio de deposito de duplicados $DUPDIR"
 	fi
 
 	LOGDIR=`grep "LOGDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$LOGDIR" ]; then
 		logWARNING "Directorio para Archivos de Log: LOGDIRno existe o es invalido  "$LOGDIR
 		return 1
 	else
 		logINFO "Se obtuvo el directorio para logs $LOGDIR"
 	fi
 
 	LOGSIZE=`grep "LOGSIZE" $CONFFILE | cut -s -f2 -d'='`
	
	if ! isInteger "$LOGSIZE"; then
 		logWARNING "LOGSIZE: no existe o es invalido "$LOGSIZE
 		return 1
 	else
 	 	logINFO "Se obtuvo el valor de LOGSIZE $LOGSIZE"
 	fi
 	return 0
}

function showDirectory(){
  if [ -d "$1" ]
  then
    if [ "$(ls -A $1)" ]
    then      
      local var="Contenido: "
      for file in $1/* ;
      do
        if [ ${#var} -ge 70 ]
        then
          logINFO "$var"
          var=""         
        fi
        var=$var" ${file##*/}"
      done
      if [ ${#var} -ge 1 ]
      then
        logINFO "$var"
      fi
    else
    logWARNING "Directorio vacio."
    fi
  else
    logWARNING "Directorio no existe."
  fi
}

function exportEnvVar(){
export BINDIR
export CONFDIR
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
export VAREXPORTED="YES"

logINFO "Se exporto la variable BINDIR:  $BINDIR"
logINFO "Se exporto la variable MAEDIR:  $MAEDIR"
logINFO "Se exporto la variable NOVEDIR:  $NOVEDIR"
logINFO "Se exporto la variable DATASIZE:  $DATASIZE"
logINFO "Se exporto la variable ACEPDIR:  $ACEPDIR"
logINFO "Se exporto la variable RECHDIR:  $RECHDIR"
logINFO "Se exporto la variable PROCDIR:  $PROCDIR"
logINFO "Se exporto la variable INFODIR:  $INFODIR"
logINFO "Se exporto la variable DUPDIR:  $DUPDIR"
logINFO "Se exporto la variable LOGDIR:  $LOGDIR"
logINFO "Se exporto la variable LOGSIZE:  $LOGSIZE"
logINFO "Se agrego BINDIR al PATH. PATH= $PATH"

}


function usetEnvVar(){
export BINDIR=""
export MAEDIR=""
export NOVEDIR=""
export DATASIZE=""
export ACEPDIR=""
export RECHDIR=""
export PROCDIR=""
export INFODIR=""
export DUPDIR=""
export LOGDIR=""
export LOGSIZE=""
export VAREXPORTED=""
}
