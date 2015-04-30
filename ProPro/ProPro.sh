#!/bin/bash
source ProProAuxFunctions.sh
source ProProFunctions.sh

$BINDIR/glog.sh "ProPro" "Inicio de ProPro"
cantFile=`ls 'ACEPDIR/' | wc -l`
$BINDIR/glog.sh "ProPro" "Cantidad de archivos a procesar: $cantFile"
gestiones=$(cat $MAEDIR/gestiones.mae | sed  's/\([^;]*\);\(.*\)/\1/') 
for gest in $gestiones
do
	docs=$(ls $ACEPDIR | grep $gest | sort -t _ -k 4)
	for doc in $docs
	do
		$BINDIR/glog.sh "ProPro" "Archivo a procesar: $doc"
		if [ -a $PROCDIR/$gest/$doc ]
		then
			$BINDIR/glog.sh "ProPro" "Se rechaza el archivo por estar duplicado."
			$BINDIR/mover.sh  $ACEPDIR/$doc $RECHDIR "ProPro" 
		else
			normaEmisor=`echo $doc | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\(.*\)/\2;\3/'`
			hasNorma=`cat $MAEDIR/tab/nxe.tab | grep $normaEmisor`
			if [ -z $hasNorma ]
			then
				if [ -a $PROCDIR/$gest ]
				then
					$BINDIR/mover.sh $ACEPDIR/$doc $PROCDIR/$gest/$doc "ProPro"
					echo '1'
				else
					echo '2'
					mkdir $PROCDIR/$gest
					$BINDIR/mover.sh $ACEPDIR/$doc $PROCDIR/$gest/$doc "ProPro"
				fi
			else
				$BINDIR/glog.sh "ProPro" "Se rechaza el archivo. Emisor no habilitado en este tipo de norma."
				$BINDIR/mover.sh $ACEPDIR/$doc $RECHDIR "ProPro"
			fi
			$BINDIR/glog.sh "ProPro" "Genero archivo temporal sin lineas vacias, y lo paso para procesar los registros."
			sed '/^$' $ACEPDIR/$gest/$doc > $ACEPDIR/$gest/$doc.temporal
			DOCTYPE= getDocType $doc
			writeRecordOutput $ACEPDIR/$gest/$doc.temporal $DOCTYPE
			$BINDIR/glog.sh "ProPro" "Elimino el archivo temporal sin lineas vacias que use para procesar."
			rm  $ACEPDIR/$gest/$doc.temporal
		fi
	done
done

