function checkearInstalacion(){	
	if [ ! -f $GRUPO"/"$DATAMAE"/encuestas.mae" ]; then
		exit 1
	fi
	if [ ! -f $GRUPO"/"$DATAMAE"/preguntas.mae" ]; then
		exit 1
	fi
	if [ ! -f $GRUPO"/"$DATAMAE"/encuestadores.mae" ]; then
		exit 1
	fi
	if [ ! -f $GRUPO"/"$DATAMAE"/errores.mae" ]; then
		exit 1
	fi	
	return 0
}

function checkearEntornoNoIniciado(){
	if [ "$GRUPO" == "" ]; then
		exit 1
	fi
	if [ "$CONFDIR" == "" ]; then
		exit 1o+1
	fi
	if [ "$DATAMAE" == "" ]; then
		exit 11
	fi
	if [ "$LIBDIR" == "" ]; then
		exit 1
	fi
	if [ "$BINDIR" == "" ]; then
		exit 1
	fi
	if [ "$ARRIDIR" == "" ]; then
		exit 1
	fi
	if [ "$DATASIZE" == "" ]; then
		exit 1
	fi
	if [ "$LOGSIZE" == "" ]; then
		exit 1
	fi
	if [ "$LOGDIR" == "" ]; then
		exit 1
	fi
	if [ "$LOGEXT" == "" ]; then
		exit 1
	fi			
	return 0
			

}

checkearInstalacion
checkearEntornoNoIniciado
