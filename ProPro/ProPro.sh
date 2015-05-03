#!/bin/bash
source ProProAuxFunctions.sh
source ProProFunctions.sh

$BINDIR/glog.sh "ProPro" "Inicio de ProPro"
cantDir=`ls $ACEPDIR | wc -l`
cantArchivos=0
archivosProcesados=0
archivosRechazados=0
$BINDIR/glog.sh "ProPro" "Cantidad de carpetas a analizar para procesar: $cantDir"
gestiones=$(cat $MAEDIR/gestiones.mae | sed 's-\([^;]*\);\([^/]*\)/\([^/]*\)/\([^;]*\);\(.*\)-\1;\4\3\2;\5-' |  sort -t";" -nk2 | sed 's/\([^;]*\);\(.*\)/\1/')
for gest in $gestiones
do
	if [ -z $ACEPDIR/$gest ]
	then
		$BINDIR/glog.sh "ProPro" "No se encontro nada para la gestion: $gest, se sigue."
		continue
	fi
	dir=$ACEPDIR/"$gest"
	hayArchivos=`ls $dir | wc -l`
	if [ $hayArchivos -eq 0 ]
	then
		$BINDIR/glog.sh "ProPro" "No hay archivos para procesar para la gestion: $gest, se sigue."
		continue
	else
		cantArchivos=$(( cantArchivos + $hayArchivos ))
	fi
	$BINDIR/glog.sh "ProPro" "Archivos a procesar de $gest: $hayArchivos"
	docs=$(ls $dir | sort -t"_" -k5)
	for doc in $docs
	do
		if [ -a $PROCDIR/proc/$doc ]
		then
			$BINDIR/glog.sh "ProPro" "Se rechaza el archivo $doc por estar duplicado."
			archivosRechazados=$(( archivosRechazados + 1 ))
			$BINDIR/mover.sh  $ACEPDIR/$dir/$doc $RECHDIR "ProPro" 
		else
			normaEmisor=`echo $doc | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\(.*\)/\2;\3/'`
			hasNorma=`cat $MAEDIR/tab/nxe.tab | grep $normaEmisor`
			if [ -z $hasNorma ]
			then
				$(chequearOCreaSubdirectorio $PROCDIR "$dir")
				$BINDIR/mover.sh $ACEPDIR/$dir/$doc $PROCDIR/$dir/$doc "ProPro"
			else
				$BINDIR/glog.sh "ProPro" "Se rechaza el archivo. Emisor no habilitado en este tipo de norma."
				archivosRechazados=$(( archivosRechazados + 1 ))
				$BINDIR/mover.sh $dir/$doc $RECHDIR "ProPro"
				continue
			fi
			$BINDIR/glog.sh "ProPro" "Genero archivo temporal sin lineas vacias, y lo paso para procesar los registros."
			sed '/^$' $PROCDIR/$dir/$doc > $PROCDIR/$dir/$doc.temporal
			DOCTYPE= getDocType $doc
			archivosProcesados=$(( archivosProcesados + 1 ))
			writeRecordOutput $PROCDIR/$dir/$doc.temporal $DOCTYPE
			$BINDIR/glog.sh "ProPro" "Elimino el archivo temporal sin lineas vacias que use para procesar."
			rm  $PROCDIR/$dir/$doc.temporal
		fi
	done
done
$BINDIR/glog.sh "ProPro" "Archivos teoricamente a procesar: $cantArchivos."
$BINDIR/glog.sh "ProPro" "Archivos rechazados: $archivosRechazados."
$BINDIR/glog.sh "ProPro" "Archivos procesados: $archivosProcesados."

