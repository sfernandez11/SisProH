#!/bin/bash 
########################################################################
#                                                                      #
# Funciones usadas para la Recepcion de Documentos (RecPro)            #
#                                                                      #
########################################################################



#INFORMA AL LOG SOBRE LA EJECUCION
function logInfo(){
    echo RecPro $1
}

#INFORMA AL LOG DE ERRORES OCURRIDOS EN LA EJECUCION
function logError(){
    logInfo $1 "ERROR"
}

#PROCESA LAS NOVEDADES, MUEVE LOS ARCHIVOS A LOS DIRECTORIOS
function procesarNovedades(){		
	
for file in $1
 do
	if VerificarTipo "$file";
	then 
		if VerificarFormato "$file";
		then 
			if verificarCOD_GESTION "$file" "$2/gestion.mae";
			then
				if verificarCOD_NORMA "$file" "$2/normas.mae";
				then
					if verificarCOD_EMISOR "$file" "$2/emisores.mae";
					then
						if verificar_FECHA_GESTION "$file" "$2/gestiones.mae";
						then
							echo "CAMINO FELIZ"
							aceptarArchivo $file $3
						fi	
					fi	
				fi	
			fi
		fi
	fi		
done 
}


#VERIFICA ARCHIVOS QUE SEAN SOLO DE TEXTO
function VerificarTipo(){	
	
local tipe=`file $1`	

if !(echo $tipe | grep '.*text$' &>/dev/null) 
	then 
		rechazarArchivo $1
		logInfo "Rechazado  ${1##*/}  - Tipo invalido" "INFO"
		return 1
	else
		return 0
fi
}

#VERIFICA ARCHIVOS TENGAN CANTIDAD DE SEPARADORES DE FORMATO

function VerificarFormato(){
	
if !(echo ${1##*/} | grep '^.*_.*_.*_[1-9]\{1,\}_[^_]*$' &>/dev/null) 
	then 
		#../mover.sh $1 "$RECHDIR"
		logInfo "Rechazado ${1##*/} - Formato de Nombre incorrecto" "INFO"
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
		#../mover.sh $1 "$RECHDIR"
		logInfo "Rechazado ${1##*/} - Gestion inexistente" "INFO"
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
		#../mover.sh $1 "$RECHDIR"
		logInfo "Rechazado ${1##*/} - Norma inexistente" "INFO"
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
		#../mover.sh $1 "$RECHDIR"
		logInfo "Rechazado ${1##*/} - Emisor inexistente" "INFO"
		return 1
	else
		return 0
fi			
}		

#VERIFICA ARCHIVOS TENGAN FECHA CORRESPONDIENTE A LA GESTION

function verificar_FECHA_GESTION(){

local fecha_file=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\5/g'`
local codgestion=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\1/g'`		
local fecha_desde=`grep	"^$codgestion;.*;.*;.*;" "$2" | sed 's/^\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\2/g'`
local fecha_hasta=`grep	"^$codgestion;.*;.*;.*;" "$2" | sed 's/^\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/g'`	

if [ $fecha_hasta = "NULL" ]
	then
		#Fecha actual
		local fecha_hasta=`date +%Y%m%d`
fi

if !(verificar_FECHA "$fecha_file" "$fecha_desde" "$fecha_hasta");
	then
		#../mover.sh $1 "$RECHDIR"
		logInfo "Rechazado ${1##*/} - Fecha no coresponde a Gestion" "INFO"
		return 1
	else
		return 0
fi
}	
	  
function verificar_FECHA(){
	
local anio_file=`echo "$1" | sed 's-\([0-3][0-9]\)\([0-1][0-9]\)\([1-2][0-9][0-9][0-9]\)-\3-g'`
local mes_file=`echo "$1" | sed 's-\([0-3][0-9]\)\([0-1][0-9]\)\([1-2][0-9][0-9][0-9]\)-\2-g'`
local dia_file=`echo "$1" | sed 's-\([0-3][0-9]\)\([0-1][0-9]\)\([1-2][0-9][0-9][0-9]\)-\1-g'`

local anio_desde=`echo "$2" | sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\)-\3-g'`
local mes_desde=`echo "$2" | sed 's-\([0-3][0-9]\)\/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\)-\2-g'`
local dia_desde=`echo "$2" | sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\)-\1-g'`

local anio_hasta=`echo "$3" | sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)\/\([1-2][0-9][0-9][0-9]\)-\3-g'`
local mes_hasta=`echo "$3" | sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\)-\2-g'`
local dia_hasta=`echo "$3" | sed 's-\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\)-\1-g'`


if [ $anio_desde = $anio_file ] || [ $anio_file = $anio_hasta ]
	then
		if [ $mes_desde = $mes_file ] && [ $mes_file = $mes_hasta ]
			then
				if [ $dia_desde \< $dia_file ] && [ $dia_file \< $dia_hasta ]
					then
						return 0
					else
						return 1
				fi
			else
				if [ $mes_desde \< $mes_file ] && [ $mes_file \< $mes_hasta ]
					then
						return 0
					else
						return 1
				fi
		fi
	else
		if [ $anio_desde \< $anio_file ] && [ $anio_file \< $anio_hasta ]
			then
				return 0
			else
				return 1
		fi
fi
}		
	
# Acepta los archivos con formato de nombre correcto a 
# ACEPDIR/<cod_gestion>/<nombredelArchivo>
# Si el subdirectorio <cod_gestion> no existe se crea.
# Se graba en el LOG : mensaje aceptado, subdirectorio y filename

function aceptarArchivo(){
	
	../mover.sh $1 $2
	
}

function rechazarArchivo(){
	
	../mover.sh $1 $2
}


