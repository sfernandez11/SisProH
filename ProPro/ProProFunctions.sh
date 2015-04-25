#!/bin/bash

#Funcion que se encarga de armar los registros de salida para los registros históricos, corrientes
# y rechazados.

#recibe por parametros: 
# $1 archivo de input
# $2 tipo de registro siendo "HIST" registros historicos, "CORR" registros corrientes, y "RECH" registros rechazados
# $3 en caso de ser un registro rechazado, en esta variable viene el motivo del rechazo

function writeRecordOutput() {
	local i=0
	while read line
	do
		if [ $i -eq 0  ]
		then
			i=$(( i + 1))
			continue
		fi
		local fechaNorma=`echo $line | sed 's/^\([^;]*\);\(.*\)/\1/'`
		#echo "$fechaNorma"
		local anioNorma=`echo $fechaNorma | cut -d "/" -f3`
		#echo "$anioNorma"
		local datosRestantesRegistro=`echo $line | sed 's/^\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\(.*\)/\3;\4;\5;\6;\7;\8;\9/'`
		#echo "$datosRestantesRegistro"
		local datosFinalRegistro=`echo $1 | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\(.*\)/\1;\2;\3/'`
		#echo "$datosFinalRegistro"
		#codigo de gestion para cuando guardo los archivos
		local codigoGestion=`echo $1 | cut -d "_" -f1`
		#echo "$codigoGestion"
		local codigoNorma=`echo $1 | cut -d "_" -f2`
		#echo "$codigoNorma"	 
		numeroNorma=0		
			
		if [ $2 = "HIST" ]
		then
			numeroNorma=`echo $line | cut -d ";" -f2`
			#echo "$numeroNorma"
		elif [ "$2" = "CORR" ]
		then
			local codigoEmisor=`echo $1 | cut -d "_" -f3`
			local anioEnCurso=`date +%d-%m-%Y | cut -d "-" -f3`
			obtenerNumeroNormaCorriente $codigoGestion $anioEnCurso $codigoEmisor $codigoNorma
		fi
		if [ $2 = "HIST" -o $2 = "CORR" ]
		then
			local registroGuardar="$1;$fechaNorma;$numeroNorma;$anioNorma;$datosRestantesRegistro;$datosFinalRegistro"		
			$(chequearOCreaSubdirectorioCodGestion $codigoGestion)						
			echo "$registroGuardar" >> $PROCDIR/$codigoGestion/$anioNorma.$codigoNorma
			$BINDIR/glog.sh "ProPro" "Se guardo el registro $registroGuardar en el directorio $codigoGestion con el nombre $anioNorma.$codigoNorma" 		
		elif [ $2 = "RECH" ]
		then
			echo "$1;"$3";$fechaNorma;$numeroNorma;$datosRestantesRegistro" >> $PROCDIR/$codigoGestion.rech
			$BINDIR/glog.sh "ProPro" "Se guardo el registro $1;$3;$fechaNorma;$numeroNorma;$datosRestantesRegistro con el nombre $codigoGestion.rech"
		else
			return 1
		fi
	done < "$1"
	$BINDIR/glog.sh "ProPro" "Se termino de procesar el archivo $1"
return 0

}

#Obtiene el numero de la norma de la tabla y actualiza el valor en la tabla.
#En caso de no existir, la crea e inicializa.
#Parametros $1 codigoGestion $2 anioEnCurso $3 codigoEmisor $4 codigoNorma
function obtenerNumeroNormaCorriente () {
	$BINDIR/glog.sh "ProPro" "Entrando a obtener el numero de la norma de la tabla axg.tab"
	archivo=$MAEDIR/tab/axg.tab
	local resultadoGrep=`grep -n "^[^;]*;$1;$2;$3;$4;" $archivo`
	if [ -z $resultadoGrep ]
	then
		$BINDIR/glog.sh "ProPro" "No se encontro la norma, procediendo a crear un contador para el codigo de norma y emisor"
		numeroNorma=1
		#Agrego al final de la tabla un nuevo contador para el codigo de norma y emisor
		local cantLineasArchivo=`wc -l $archivo | cut -d " " -f1`
		local idContadorActual=`awk "NR == $cantLineasArchivo" $archivo | cut -d ";" -f1`
		(( idContadorActual++ ))
		local usuario=`whoami`
		fecha=`date +%d/%m/%Y`
		echo "$idContadorActual;"$1";"$2";"$3";"$4";2;"$usuario";"$fecha"" >> $archivo
		$BINDIR/glog.sh "ProPro" "Agregado el contador para el codigo de norma $4 y codigo de emisor $3"
	else
		$BINDIR/glog.sh "ProPro" "Se encontro la norma en la tabla, se tomara el numero de norma y se actualizara el valor en la tabla"
		local numeroLinea=`echo $resultadoGrep | cut -d ":" -f1`
		numeroNorma=`echo $resultadoGrep | cut -d ";" -f6`
		$(incrementarNumeroEnTabla $(( numeroNorma + 1)) $numeroLinea)
		$BINDIR/glog.sh "ProPro" "Se incremento el numero de norma en la tabla para el codigo de norma $4 y codigo de emisor $3"
	fi
	return 0	
}

#Incrementa en 1 el contador de la tabla para el codigo de norma y emisor utilizado para protocolizar
#Recibe en $1 el numero de norma a actualizar en contador y en $2 el numero de linea donde hacer la modificacion
function incrementarNumeroEnTabla () {
	sed -i ""$2"s/^\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\(.*\)/\1;\2;\3;\4;\5;"$1";\7;\8/" $archivo
	return 0
}

#Chequea si el directorio existe. En caso de no existir lo crea.
#En caso de existir un archivo con el nombre de lo que seria el nombre del directorio a generar, se elimina el archivo y se crea el directorio.
function chequearOCreaSubdirectorioCodGestion () {
	$BINDIR/glog.sh "ProPro" "Chequea si el directorio $1 existe. En caso de no existir lo crea."
	if [ -d $PROCDIR/$1 ]
	then
		$BINDIR/glog.sh "ProPro" "El directorio $1 existe."
		return 0
	else
		if [ -f $PROCDIR/$1 ]
		then
			$BINDIR/glog.sh "ProPro" "El directorio $1 no existe pero existe un archivo con ese nombre: se procede a eliminar para poder crear el directorio." "WAR"
			rm $PROCDIR/$1
		fi	
		$BINDIR/glog.sh "ProPro" "Crea el directorio $1\."
		mkdir $PROCDIR/$1
		return 0
	fi
	return 1
}
