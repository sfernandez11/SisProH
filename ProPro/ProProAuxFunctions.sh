function getDocType() {
	doc=$1
	DATE=`echo $doc | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\([^_]*\)_\(.*\)$/\5/'`
	YEAR=`echo $DATE | sed 's/^\([^-]*\)-\([^-]*\)-\(.*\)$/\3/'`
	currentYear=$(date +"%Y")
	if  (($YEAR < $currentYear)) 
	then
		#$BINDIR/glog.sh "ProPro" "El archivo es de un año anterior al actual. Historico."
		echo "HIST"
	else
		currentAdmin=`tail -1 $MAEDIR/gestiones.mae`
		currentAdminName=`echo $currentAdmin | sed 's/^\([^;]*\);\(.*\)/\1/'`
		docAdmin=`echo $doc | sed 's/^\([^_]*\)_\(.*\)/\1/'`
		if [ "$currentAdminName" = "$docAdmin" ]
		then
			#$BINDIR/glog.sh "ProPro" "El archivo es corriente."
			echo "CORR"
		else
			#$BINDIR/glog.sh "ProPro" "El archivo es de este año pero gestion previa a actual. Historico."
			echo "HIST"
		fi
	fi
}
