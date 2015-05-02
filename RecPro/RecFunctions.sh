#!/bin/bash 
########################################################################
#                                                                      #
# Funciones usadas para la Recepcion de Documentos (RecPro)            #
#                                                                      #
########################################################################

#INFORMA AL LOG SOBRE LA EJECUCION
function logInfo(){
    ./glog.sh "RecPro" "$1"
}

#INFORMA AL LOG DE ERRORES OCURRIDOS EN LA EJECUCION
function logError(){
    logInfo $1
}

#PROCESA LAS NOVEDADES, MUEVE LOS ARCHIVOS A LOS DIRECTORIOS
function procesarNovedades(){	
		
if hayNovedadesPendientes $NOVEDIR/*;
	then	
	for file in $NOVEDIR/*
	do
		if VerificarTipo "$file";
		then 
			if VerificarFormato "$file";
			then 
				if verificarCOD_GESTION "$file" "$MAEDIR/gestiones.mae";
				then
					if verificarCOD_NORMA "$file" "$MAEDIR/normas.mae";
					then
						if verificarCOD_EMISOR "$file" "$MAEDIR/emisores.mae";
						then
							if verificar_FECHA_GESTION "$file" "$MAEDIR/gestiones.mae";
							then
								aceptarArchivo $file
							fi	
						fi	
					fi	
				fi
			fi
		fi		
	done 
fi	
return 0
}


#VERIFICA ARCHIVOS QUE SEAN SOLO DE TEXTO
function VerificarTipo(){	
	
local tipe=`file $1`
local tipo=`echo $tipe | sed 's/^\(.*\):\(.*\)/\2/g'`	

if !(echo $tipo | grep '.*text$' &>/dev/null) 
	then 
		rechazarArchivo $1
		logInfo "Rechazado  ${1##*/}  - Tipo invalido : $tipo"
		return 1
	else
		return 0
fi
}

#VERIFICA ARCHIVOS TENGAN CANTIDAD DE SEPARADORES DE FORMATO

function VerificarFormato(){
	
if !(echo ${1##*/} | grep '^[^_]*_[^_]*_[^_]*_[1-9]\{1,\}_[^_]*$' &>/dev/null)

	then 
		rechazarArchivo $1
		logInfo "Rechazado ${1##*/} - Formato de Nombre incorrecto"
		return 1
	else
		return 0
fi
}
		
#VERIFICA ARCHIVOS TENGAN COD_GESTION EN MAESTRO 

function verificarCOD_GESTION(){
		
local codgestion=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\1/g'`

if !(grep "^$codgestion;.*;.*;.*;" "$2" &>/dev/null)
	then 
		rechazarArchivo $1
		logInfo "Rechazado ${1##*/} - [$codgestion] Gestion inexistente"
		return 1
	else
		return 0
fi		     
}
	

#VERIFICA ARCHIVOS TENGAN COD_NORMA EN MAESTRO

function verificarCOD_NORMA(){
	
local codnorma=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\2/g'`

if !(grep "^$codnorma;.*;" "$2" &>/dev/null)
	then 
		rechazarArchivo $1
		logInfo "Rechazado ${1##*/} - [$codnorma] Norma inexistente"
		return 1
	else
		return 0 
fi	
}
	

#VERIFICA ARCHIVOS TENGAN COD_EMISOR EN MAESTRO

function verificarCOD_EMISOR(){
	
local codemisor=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\3/g'`

if !(grep "^$codemisor;.*;.*;" "$2" &>/dev/null)
	then 
		rechazarArchivo $1
		logInfo "Rechazado ${1##*/} - [$codemisor] Emisor inexistente"
		return 1
	else
		return 0
fi			
}		

#VERIFICA ARCHIVOS TENGAN FECHA CORRESPONDIENTE A LA GESTION

function verificar_FECHA_GESTION(){

local fecha_file=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\([0-3][0-9]\)[^_]\([0-1][0-9]\)[^_]\([1-2][0-9][0-9][0-9]\)/\7\6\5/g'`
local codgestion=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\1/g'`		
local fecha_desde=`grep	"^$codgestion;.*;.*;.*;" "$2" | sed 's-^\(.*\);\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\);\(.*\);\(.*\);\(.*\)-\4\3\2-g'`
local fecha_hasta=`grep	"^$codgestion;.*;.*;.*;" "$2" | sed 's-^\(.*\);\(.*\);\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\);\(.*\);\(.*\)-\5\4\3-g'`	

if [ $fecha_hasta = "NULL" ]
	then
		#Fecha actual
		local fecha_hasta=`date +%Y%m%d`
fi

if !(verificar_FECHA "$fecha_file" "$fecha_desde" "$fecha_hasta");
	then
		rechazarArchivo $1
		logInfo "Rechazado ${1##*/} - Fecha no coresponde a Gestion"
		return 1
	else
		return 0
fi
}	
	  
function verificar_FECHA(){
	
if [ $2 \< $1 ]	&& [ $1 \< $3 ]
 then
	return 0
 else
	return 1		
fi
}		
	
# Acepta los archivos con formato de nombre correcto a 
# ACEPDIR/<cod_gestion>/<nombredelArchivo>
# Si el subdirectorio <cod_gestion> no existe se crea.
# Se graba en el LOG : mensaje aceptado, subdirectorio y filename

function aceptarArchivo(){
	
	local codgestion=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\1/g'`
	
	if [ ! -d $ACEPDIR/$codgestion ]
	then
		mkdir $ACEPDIR/$codgestion
	fi
	logInfo  "Aceptado ${1##*/} - Destino $RECHDIR/$codgestion/${1##*/}"
	./mover.sh $1 $ACEPDIR/$codgestion RecPro.sh
	return 0	
}

function rechazarArchivo(){
	
	logInfo "Movido ${1##*/} - Destino $RECHDIR/${1##*/}"
	./mover.sh  $1 $RECHDIR RecPro.sh
	return 0
}

# Si existen archivos en los subdirectorios de ACEPDIR se intenta 
# invocar el comando ProPro
# Si se pudo invocar se graba en LOG: ProPro - Corriendo  <Id>
# Si hay archivos pero esta corriendo se graba en LOG: Posponer a siguiente Ciclo
# Si surge algun error se muestra por pantalla

function novedadesPedientes(){
	
if hayNovedadesPendientes $ACEPDIR/*/;
	then
	PID=`pidof ProPro.sh`
	if [ "$PID" = "" ]; 
	then
		nohup ./ProPro.sh > /dev/null 2>&1
		PID=`pidof ProPro.sh`
		logInfo "ProPro corriendo bajo el no.: $PID"
		return 0
	else
		logInfo "Invocacion de ProPro propuesta para el siguiente ciclo"
		return 0
	fi
fi
return 0	
}

function hayNovedadesPendientes(){
	
for directorio in $1
 do		
    local dir=`find $directorio -type f | wc -l`
	if [ ! $dir -eq 0 ]
	then
		return 0
	fi
done
return 1
}
