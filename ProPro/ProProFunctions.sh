#!/bin/bash

#Funcion que se encarga de armar los registros de salida para los registros históricos, corrientes
# y rechazados.

# recibe por parametros: 
# $1 archivo de input
# $2 tipo de archivo siendo "HIST" archivos historicos, "CORR" archivos corrientes
# $3 el doc

function writeRecordOutput() {
	while read line || [[ -n "$line" ]]
	do
		local registroRechazado=''
		local motivoRechazo=''
		local fechaNorma=`echo $line | sed 's/^\([^;]*\);\(.*\)/\1/'`
		#codigo de gestion para cuando guardo los archivos
		codigoGestion=`echo $3 | cut -d "_" -f1`
		#obtengo el anio en curso para distintos chequeos.
		anioEnCurso=`date +%Y`
		if FECHA_NORMA_VALIDA=$(chequearFechaValida $fechaNorma $anioEnCurso)
		then
			if ! FECHA_NORMA_EN_RANGO_GESTION=$(chequearFechaValidaRangoGestion $fechaNorma)
			then
				registroRechazado='SI'
				motivoRechazo='Fecha fuera del rango de la gestion'
			fi
		else
			registroRechazado='SI'
			motivoRechazo='Fecha invalida'
		fi
		local anioNorma=`echo $fechaNorma | cut -d "/" -f3`
		local datosRestantesRegistro=`echo $line | sed 's/^\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\(.*\)/\3;\4;\5;\6;\7;\8;\9/'`
		local datosFinalRegistro=`echo $3 | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\(.*\)/\1;\2;\3/'`
		local codigoNorma=`echo $3 | cut -d "_" -f2`
		numeroNorma=0		
	
		if [ $2 = "HIST" ]
		then
			numeroNorma=`echo $line | cut -d ";" -f2`
			if [ $numeroNorma -le 0 ]
			then
				registroRechazado='SI'
				motivoRechazo='Numero de norma invalido'
			fi
		elif [ "$2" = "CORR" ]
		then
			local codigoEmisor=`echo $3 | cut -d "_" -f3`
			local codigoFirma=`echo $datosRestantesRegistro | sed 's/^\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\(.*\)/\6/'`
			if ! CODIGO_DE_FIRMA_VALIDO=$(chequearCodigoFirmaValido $codigoEmisor $codigoFirma)
			then
				registroRechazado='SI'
				motivoRechazo='Codigo de firma invalido'
			else
				obtenerNumeroNormaCorriente $codigoGestion $anioEnCurso $codigoEmisor $codigoNorma
			fi
		fi
		if [ -z $registroRechazado ]
		then
			local registroGuardar="$3;$fechaNorma;$numeroNorma;$anioNorma;$datosRestantesRegistro;$datosFinalRegistro"		
			$(chequearOCreaSubdirectorio $PROCDIR $codigoGestion)						
			echo "$registroGuardar" >> $PROCDIR/$codigoGestion/$anioNorma.$codigoNorma
			$BINDIR/glog.sh "ProPro" "Se guardo el registro $registroGuardar en el directorio $codigoGestion con el nombre $anioNorma.$codigoNorma"
			continue 		
		else
			echo "$3;"$motivoRechazo";$fechaNorma;$numeroNorma;$datosRestantesRegistro" >> $PROCDIR/$codigoGestion.rech
			$BINDIR/glog.sh "ProPro" "Se guardo el registro $3;$motivoRechazo;$fechaNorma;$numeroNorma;$datosRestantesRegistro con el nombre $codigoGestion.rech"
			continue
		fi
	done < "$1"
	$BINDIR/glog.sh "ProPro" "Se termino de procesar el archivo $3"
return 0

}

#Obtiene el numero de la norma de la tabla y actualiza el valor en la tabla.
#En caso de no existir, la crea e inicializa.
#Parametros $1 codigoGestion $2 anioEnCurso $3 codigoEmisor $4 codigoNorma
function obtenerNumeroNormaCorriente () {
	$BINDIR/glog.sh "ProPro" "Entrando a obtener el numero de la norma de la tabla axg.tab"
	local archivo=$MAEDIR/tab/axg.tab
	#Me creo un archivo temporal para mover el original y trabajar con el temporal y luego de modificarlo, renombrar.
	$BINDIR/glog.sh "ProPro" "Creo un archivo de tabla de contadores temporal para modificar y muevo el actual al directorio correspondiente"
	cp $archivo $MAEDIR/tab/axg.tabtemp
	archivoTemp=$MAEDIR/tab/axg.tabtemp
	$(chequearOCreaSubdirectorio $MAEDIR/tab "ant")
	$BINDIR/mover.sh "$archivo" "$MAEDIR/tab/ant" "ProPro"
	$BINDIR/glog.sh "ProPro" "Tabla de contadores preservada antes de su modificación en MAEDIR/tab/ant"
	local resultadoGrep=`grep -n "^[^;]*;$1;$2;$3;$4;" $archivoTemp`
	if [ -z $resultadoGrep ]
	then
		$BINDIR/glog.sh "ProPro" "No se encontro la norma, procediendo a crear un contador para el codigo de norma y emisor"
		numeroNorma=1
		#Agrego al final de la tabla un nuevo contador para el codigo de norma y emisor
		local cantLineasArchivo=`wc -l $archivoTemp | cut -d " " -f1`
		local idContadorActual=`awk "NR == $cantLineasArchivo" $archivoTemp | cut -d ";" -f1`
		idContadorActual=$(( idContadorActual + 1))
		local usuario=`whoami`
		fecha=`date +%d/%m/%Y`
		echo "$idContadorActual;"$1";"$2";"$3";"$4";2;"$usuario";"$fecha"" >> $archivoTemp
		$BINDIR/glog.sh "ProPro" "Agregado el contador para el codigo de norma $4 y codigo de emisor $3"
	else
		$BINDIR/glog.sh "ProPro" "Se encontro la norma en la tabla, se tomara el numero de norma y se actualizara el valor en la tabla"
		local numeroLinea=`echo $resultadoGrep | cut -d ":" -f1`
		numeroNorma=`echo $resultadoGrep | cut -d ";" -f6`
		numeroNorma=$(( numeroNorma + 1))
		$(incrementarNumeroEnTabla $numeroNorma $numeroLinea)
		$BINDIR/glog.sh "ProPro" "Se incremento el numero de norma en la tabla para el codigo de norma $4 y codigo de emisor $3"
	fi
	#Renombro mi archivo temporal de tabla de contadores por su nombre original.
	mv $archivoTemp $archivo
	return 0	
}

#Incrementa en 1 el contador de la tabla para el codigo de norma y emisor utilizado para protocolizar
#Recibe en $1 el numero de norma a actualizar en contador y en $2 el numero de linea donde hacer la modificacion
function incrementarNumeroEnTabla () {
	sed -i ""$2"s/^\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\([^;]*\);\(.*\)/\1;\2;\3;\4;\5;"$1";\7;\8/" $archivoTemp
	return 0
}

#Chequea si el directorio existe. En caso de no existir lo crea. En $1 recibe el directorio donde revisa y en $2 la variable del directorio a crear.
#En caso de existir un archivo con el nombre de lo que seria el nombre del directorio a generar, se elimina el archivo y se crea el directorio.
function chequearOCreaSubdirectorio () {
	$BINDIR/glog.sh "ProPro" "Chequea si el directorio $2 existe. En caso de no existir lo crea."
	if [ -d $1/$2 ]
	then
		$BINDIR/glog.sh "ProPro" "El directorio $2 existe."
		return 0
	else
		if [ -f $1/$2 ]
		then
			$BINDIR/glog.sh "ProPro" "El directorio $2 no existe pero existe un archivo con ese nombre: se procede a eliminar para poder crear el directorio." "WAR"
			rm $1/$2
		fi	
		$BINDIR/glog.sh "ProPro" "Crea el directorio $2."
		mkdir $1/$2
		return 0
	fi
	return 1
}

#Chequea si la fecha con formato dd/mm/aaaa es una fecha valida. En caso de serlo devuelve 0, sino 1.
#Recibe en $1 la fecha a analizar y en $2 en anio en curso
function chequearFechaValida() {
	$BINDIR/glog.sh "ProPro" "Chequeando si la fecha de la norma es una fecha valida"
	local dia=`echo $1 | cut -d "/" -f1`
	if [ $dia -lt 1 -o $dia -gt 31 ]
	then
		return 1
	fi
	local mes=`echo $1 | cut -d "/" -f2`	
	if [ $mes -lt 1 -o $mes -gt 12 ]
	then
		return 1
	fi
	local anio=`echo $1 | cut -d "/" -f3`
	if [ $anio -lt 1900 -o $anio -gt $2 ]
	then
		return 1
	fi
	return 0
}

#Chequea si la fecha pasada en parametro $1 esta en el rango de la gestion.
#En caso de estar devuelve 0, en caso de no, 1.
function chequearFechaValidaRangoGestion(){
	$BINDIR/glog.sh "ProPro" "Chequeando si la fecha de la norma esta dentro del rango de la gestion"
	local archivoMaestroGestiones=$MAEDIR/gestiones.mae
	local resultGrep=`grep "^$codigoGestion;" $archivoMaestroGestiones`	
	local fechaDesde=`echo $resultGrep | cut -d ";" -f2`
	local fechaHasta=`echo $resultGrep | cut -d ";" -f3`
	if [ $fechaHasta = "NULL" ]
	then
		fechaHasta=`date +%d/%m/%Y`
	fi
	
	#obtengo datos de la fecha de la norma para re formatearla para analisis
	local anio=`echo $1 | cut -d "/" -f3`
	local mes=`echo $1 | cut -d "/" -f2`
	local dia=`echo $1 | cut -d "/" -f1`	
	#obtengo datos de las fechas de las gestiones para reformatearlas para analisis
	local anioDesde=`echo $fechaDesde | cut -d "/" -f3`
	local mesDesde=`echo $fechaDesde | cut -d "/" -f2`
	local diaDesde=`echo $fechaDesde | cut -d "/" -f1`
	local anioHasta=`echo $fechaHasta | cut -d "/" -f3`
	local mesHasta=`echo $fechaHasta | cut -d "/" -f2`
	local diaHasta=`echo $fechaHasta | cut -d "/" -f1`
	#los reformateo como un unico valor sin separador por orden de relevancia
	fechaDesde="$anioDesde$mesDesde$diaDesde"
	fechaHasta="$anioHasta$mesHasta$diaHasta"
	local fechaNorma="$anio$mes$dia"

	if [ "$fechaNorma" -ge "$fechaDesde" -a "$fechaNorma" -le "$fechaHasta"  ]
	then
		return 0
	else
		return 1
	fi	
}

#chequea que el $2 codigo de firma sea valido para el $1 codigoEmisor
function chequearCodigoFirmaValido() {
	$BINDIR/glog.sh "ProPro" "Chequeando que la firma del emisor sea valida"	
	local archivoEmisores=$MAEDIR/emisores.mae		
  	local resultaGrep=`grep "^$1;" $archivoEmisores`
	local firmaDigital=`echo $resultaGrep | cut -d ";" -f3`
	if [ $2 = $firmaDigital ]
	then
		return 0
	fi
	return 1	
}

