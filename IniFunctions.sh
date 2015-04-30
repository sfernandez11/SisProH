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
    #chmod +x $BINDIR"/Start.sh"
    #chmod +x $BINDIR"/RecPro.sh"
    #chmod +x $BINDIR"/Stop.sh"
    DIE=1
    local file
    for file in $BINDIR/* ;
    do
       if [ ! -x "$file" ]
       then
         echo "No tiene permisos para ejecutar ${file##*/}"
         DIE=0
       fi
    done
    return $DIE  
}


function listFiles(){
echo "Hola" #TODO listar archivos en dir
}


function startDeamon(){
	Start.sh RecPro
}

function noStartDeamon(){
	echo "Ok, no empezamos. Podes arrancarlo manualmente con $ Start.sh"
}

function askStartDeamon(){
	echo "Desea efectuar la activación de RecPro? Si – No"

	select yn in "Si" "No"; do
	    case $yn in
	        Si ) startDeamon; break;;
	        No ) noStartDeamon; break;;
			* ) echo "Por favor, seleccione una opcion";;
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