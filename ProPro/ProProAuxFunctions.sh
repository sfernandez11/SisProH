function getDocType() {
	#doc="Alfonsin_RES_1001_383_23-05-1988"
	doc=$1
	DATE=`echo $doc | sed 's/^\([^_]*\)_\([^_]*\)_\([^_]*\)_\([^_]*\)_\([^_]*\)/\5/'`
	YEAR=`echo $DATE | sed 's/^\([0-9]*-[0-9]*-\)\([0-9]*\)/\2/'`
	currentYear=$(date +"%Y")
	if  (($YEAR < $currentYear)); 
	then
		echo "HIST";
	else
		currentAdmin=`tail -1 ${PWD}/MAEDIR/gestiones.mae`
		currentAdminName=`echo $currentAdmin | sed 's/^\([^;]*\);\(.*\)/\1/'`
		docAdmin=`echo $doc | sed 's/^\([^_]*\)_\(.*\)/\1/'`
		if [ "$currentAdminName" = "$docAdmin" ]
		then
			echo "CORR";
		else
			echo "HIST";
		fi
	fi
}
