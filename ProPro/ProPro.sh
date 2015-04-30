#!/bin/bash
source ProProAuxFunctions.sh
source ProProFunctions.sh

export LOGDIR=${PWD}/LOGDIR
export LOGSIZE=600
sh ../glog.sh "ProPro" "Inicio de ProPro"
cantFile=`ls 'ACEPDIR/' | wc -l`
sh ../glog.sh "ProPro" "Cantidad de archivos a procesar: $cantFile"
gestiones=$(cat $MAEDIR/gestiones.mae | sed  's/\([^;]*\);\(.*\)/\1/') 
for gest in $gestiones
do
	docs=$(ls $ACEPDIR | grep $gest | sort -t _ -k 4)
	for doc in $docs
	do
		sh ../glog.sh "ProPro" "Archivo a procesar: $doc"
		if [ -a $PROCDIR/$gest/$doc ]
		then
			sh ../glog.sh "ProPro" "Se rechaza el archivo por estar duplicado."
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
				sh ../glog.sh "ProPro" "Se rechaza el archivo. Emisor no habilitado en este tipo de norma."
				$BINDIR/mover.sh $ACEPDIR/$doc $RECHDIR "ProPro"
			fi
			sed '/^$' $ACEPDIR/$gest/$doc > $ACEPDIR/$gest/tmp/$doc
			DOCTYPE= getDocType $doc
			writeRecordOutput $ACEPDIR/$gest/tmp/$doc $DOCTYPE
			rm  $ACEPDIR/$gest/tmp/$doc
		fi
	done
done

