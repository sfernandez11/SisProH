source InsFunctions.sh

function log(){
	if [ $BINDIR != "" ];then
        	$BINDIR/glog.sh "IniPro" "$1" "$2" #1= log message, 2= log level
        fi
}

function logINFO(){
	echo "[INFO]" $1 
	log "$1" "INFO" #1= log message, 2= log level
}	
function logERROR(){
	echo "[ERROR]" $1
	log "$1" "ERR"
}

function logWARNING(){
	echo "[WARNING]" "$1" 
	log "$1" "WAR"
}

function checkMaeFiles(){	
	if [ ! -f $MAEDIR"/encuestas.mae" ]; then
		return 1
	fi
	if [ ! -f $MAEDIR"/preguntas.mae" ]; then
		return 1
	fi
	if [ ! -f $MAEDIR"/encuestadores.mae" ]; then
		return 1
	fi
	if [ ! -f $MAEDIR"/errores.mae" ]; then
		return 1
	fi	
	return 0
}

function confFileNotFound(){	
	if [ -f $GRUPO"/conf/InsPro.conf" ]; then
		return 1
	fi	
	return 0
}

function checkBinFiles(){
	if [ ! -f $BINDIR"/RecPro.sh" ]; then
		return 1
	fi	
	return 0
}

function checkTableFiles(){
	if [ ! -f $MAEDIR"/tab/nxe.tab" ]; then
		return 1
	fi
	if [ ! -f $MAEDIR"/tab/axg.tab" ]; then
		return 1
	fi	
	return 0
}

function permissionsMissing(){       
    local file
    for file in $BINDIR/* ;
    do
       if [ ! -x "$file" ]
       then
         logINFO "No tiene permisos para ejecutar ${file##*/}"
         chmod +x $file
         if [ ! -x "$file" ]; then
         	logERROR "No se pudo setear permisos para ejecutar ${file##*/}"
         	return 1
         elif 
         	logINFO "Se setearon permisos para ejecutar ${file##*/} correctamente"
         fi
       fi
    done
    return 0
}


function startDeamon(){
	Start.sh RecPro
}

function noStartDeamon(){
	logINFO "No se inicio el demonio. Puede arrancarlo manualmente con $ Start.sh RecPro"
}

function askStartDeamon(){
	echo "Desea efectuar la activación de RecPro? Si – No"

	select yn in "Si" "No"; do
	    case $yn in
	        Si ) startDeamon; break;;
	        No ) noStartDeamon; break;;
			* ) echo "Por favor, seleccione una opcion valida (1/2)";;
	    esac
	done
}

function checkAmbiente(){
	if [ "$BINDIR" != "" ]; then
		echo "La variable BINDIR ya contiene el valor"$BINDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$MAEDIR" != "" ]; then
		echo "La variable MAEDIR ya contiene el valor"$MAEDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$NOVEDIR" != "" ]; then
		echo "La variable NOVEDIR ya contiene el valores: "$NOVEDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$DATASIZE" != "" ]; then
		echo "La variable DATASIZE ya contiene el valor es: "$DATASIZE". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$ACEPDIR" != "" ]; then
		echo "La variable ACEPDIR ya contiene el valores: "$ACEPDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$RECHDIR" != "" ]; then
		echo "La variable RECHDIR ya contiene el valor "$RECHDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$PROCDIR" != "" ]; then
		echo "La variable PROCDIR ya contiene el valor "$PROCDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$INFODIR" != "" ]; then
		echo "La variable INFODIR ya contiene el valor "$INFODIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$DUPDIR" != "" ]; then
		echo "La variable DUPDIR ya contiene el valor"$DUPDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$LOGDIR" != "" ]; then
		echo "La variable LOGDIR ya contiene el valor"$LOGDIR". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi

	if [ "$LOGSIZE" != "" ]; then
		echo "La variable LOGSIZE ya contiene el valor "$LOGSIZE". Si quiere reiniciar termine su sesion e ingrese nuevamente"
		return 1
	fi	

	return 0
}

function ambienteVacio(){
	
	if [  "BINDIR" == "" ]; then
		echo "La variable BINDIR no se encuentra definida"
		return 0
	fi

	if [ "$MAEDIR" == "" ]; then
		echo "La variable MAEDIR no se encuentra definida"
		return 0
	fi

	if [ "$NOVEDIR" == "" ]; then
		echo "La variable NOVEDIR no se encuentra definida"
		return 0
	fi

	if [ "$DATASIZE" == "" ]; then
		echo "La variable DATASIZE no se encuentra definida"
		return 0
	fi

	if [ "$ACEPDIR" == "" ]; then
		echo "La variable ACEPDIR no se encuentra definida"
		return 0
	fi

	if [ "$RECHDIR" == "" ]; then
		echo "La variable RECHDIR no se encuentra definida"
		return 0
	fi

	if [ "$PROCDIR" == "" ]; then
		echo "La variable PROCDIR no se encuentra definida"
		return 0
	fi

	if [ "$INFODIR" == "" ]; then
		echo "La variable INFODIR no se encuentra definida"
		return 0
	fi

	if [ "$DUPDIR" == "" ]; then
		echo "La variable DUPDIR no se encuentra definida"
		return 0
	fi

	if [ "$LOGDIR" == "" ]; then
		echo "La variable LOGDIR no se encuentra definida"
		return 0
	fi

	if [ "$LOGSIZE" == "" ]; then
		echo "La variable LOGSIZE no se encuentra definida"
		return 0
	fi
	return 1
}

function getPid(){
    local ppid=`ps aux | grep "\($BINDIR\)\?/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    echo $ppid
}

function readVariables(){

 	BINDIR=`grep "BINDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$BINDIR"]; then
 		logERROR "Directorio de Ejecutables: BINDIR no existe o es invalido "$BINDIR
 		return 1		
 	fi
 
 	MAEDIR=`grep "MAEDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$MAEDIR" ]; then
 		logERROR "Directorio de Maestros y Tablas: MAEDIR no existe o es invalido "$MAEDIR	
 	fi
 
 	NOVEDIR=`grep "NOVEDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$NOVEDIR" ]; then
 		logERROR "Directorio de recepción de documentos para protocolización: NOVEDIR no existe o es invalido "$NOVEDIR
 		return 1
 	fi
 
 	DATASIZE=`grep "DATASIZE" $CONFFILE | cut -s -no existe o es invalido f2 -d'='`

	if [ ! isInteger "$DATASIZE" ]; then
 		logERROR "DATASIZE no existe o es invalido "$DATASIZE
 		return 1
 	fi
 
 	ACEPDIR=`grep "ACEPDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$ACEPDIR" ]; then
 		logERROR "Directorio de Archivos Aceptados: ACEPDIR no existe o es invalido "$ACEPDIR
 		return 1
 	fi
 
 	RECHDIR=`grep "RECHDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$RECHDIR" ]; then
 		logERROR "Directorio de Archivos Rechazados: RECHDIR no existe o es invalido "$RECHDIR
 		return 1
 	fi
 
 	PROCDIR=`grep "PROCDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$PROCDIR" ]; then
 		logERROR "Directorio de Archivos Protocolizados: PROCDIR no existe o es invalido "$PROCDIR
 		return 1
 	fi
 
 	INFODIR=`grep "INFODIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$INFODIR" ]; then
 		logERROR "Directorio para informes y estadísticas: INFODIR no existe o es invalido "$INFODIR
 		return 1
 	fi
 
 	DUPDIR=`grep "DUPDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$DUPDIR" ]; then
 		logERROR "Nombre para el repositorio de duplicados: DUPDIRno existe o es invalido  "$DUPDIR
 		return 1
 	fi
 
 	LOGDIR=`grep "LOGDIR" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! -d "$LOGDIR" ]; then
 		logERROR "Directorio para Archivos de Log: LOGDIRno existe o es invalido  "$LOGDIR
 		return 1
 	fi
 
 	LOGSIZE=`grep "LOGSIZE" $CONFFILE | cut -s -f2 -d'='`
	
	if [ ! isInteger "$LOGSIZE" ]; then
 		logERROR "LOGSIZE: no existe o es invalido "$LOGSIZE
 		return 1
 	fi

 	return 0

}
