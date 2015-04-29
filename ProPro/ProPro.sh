#!/bin/bash
source aux.sh
#source ProProFunctions.sh

export LOGDIR=${PWD}/LOGDIR
export LOGSIZE=600
sh ../glog.sh "ProPro" "Inicio de ProPro"
cantFile=`ls 'ACEPDIR/' | wc -l`
sh ../glog.sh "ProPro" "Cantidad de archivos a procesar: $cantFile"
ACEPDIR=ACEPDIR
MAEDIR=MAEDIR
RECHDIR=RECHDIR
PROCDIR=PROCDIR
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
			mv $ACEPDIR/$doc $RECHDIR 
		else
			normaEmisor=`echo $doc | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\(.*\)/\2;\3/'`
			hasNorma=`cat $MAEDIR/tab/nxe.tab | grep $normaEmisor`
			if [ -z $hasNorma ]
			then
				if [ -a $PROCDIR/$gest ]
				then
					mv $ACEPDIR/$doc $PROCDIR/$gest/$doc
					echo '1'
				else
					echo '2'
					mkdir $PROCDIR/$gest
					mv $ACEPDIR/$doc $PROCDIR/$gest/$doc
				fi
			else
				sh ../glog.sh "ProPro" "Se rechaza el archivo. Emisor no habilitado en este tipo de norma."
				mv $ACEPDIR/$doc $RECHDIR
			fi
			sed '/^$' $ACEPDIR/$gest/$doc > $ACEPDIR/$gest/tmp/$doc
			writeRecordOutput $ACEPDIR/$gest/tmp/$doc 'HIST'
		fi
	done
done


#Para llamar a Agustin: writeRecordOutpu $1 archivos, $2 HIST o CORR o RECH. $3 MOTIVO de rech
