#!/bin/bash 
########################################################################
#                                                                      #
# Funciones usadas para la Recepcion de Documentos (RecPro)            #
#                                                                      #
########################################################################

#INFORMA AL LOG SOBRE LA EJECUCION
function logInfo(){
    glog.sh "RecPro" "$1"
}

#INFORMA AL LOG DE ERRORES OCURRIDOS EN LA EJECUCION
function logError(){
    glog.sh "RecPro" "$1" "ERR"
}

#PROCESA LAS NOVEDADES, MUEVE LOS ARCHIVOS A LOS DIRECTORIOS
function procesarNovedades(){	

if hayNovedadesPendientes $NOVEDIR;
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

if !(echo $tipo | grep '^.*text.*$' &>/dev/null) 
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

local separadores=""
local numero=""
local fecha=""	
	
if !(echo ${1##*/} | grep '^[^_]*_[^_]*_[^_]*_[^_]*_[^_]*$' &>/dev/null)
 then
	separadores="N° de Campos" 	
fi
	
if !(echo ${1##*/} | grep '^[^_]*[_][^_]*[_][^_]*[_][0-9]\{1,\}[_][^_]*$' &>/dev/null)
 then
	numero=" N°de Archivo"
fi
	
if !(echo ${1##*/} | grep '^[^_]*_[^_]*_[^_]*_[^_]*_\([0-9][0-9]\)-\([0-9][0-9]\)-\([0-9][0-9][0-9][0-9]\)$' &>/dev/null)
 then
	fecha=" Fecha dd-mm-aaaa"
fi	

if [ -z "$separadores" ] && [ -z "$numero" ] && [ -z "$fecha" ]; then 

		return 0
	else
		rechazarArchivo $1
		logInfo "Rechazado ${1##*/} - Formato de Nombre incorrecto :$separadores $numero $fecha"
		return 1

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
local fecha_hasta=`grep	"^$codgestion;.*;.*;.*;" "$2" | sed 's/^\(.*\);\(.*\);\(.*\);\(.*\);\(.*\)/\3/g'`	

if [ $fecha_hasta = "NULL" ]
	then
		#Fecha actual
		fecha_hasta=`date +%Y%m%d`
	else
	    fecha_hasta=`grep "^$codgestion;.*;.*;.*;" "$2" | sed 's-^\(.*\);\(.*\);\([0-3][0-9]\)/\([0-1][0-9]\)/\([1-2][0-9][0-9][0-9]\);\(.*\);\(.*\)-\5\4\3-g'`
fi

if !(verificar_FECHA "$fecha_file" "$fecha_desde" "$fecha_hasta");
	then
		rechazarArchivo $1
    local hoy=`date +%Y%m%d`
    if [ $hoy -lt $fecha_file ]
    then
      logInfo "Rechazado ${1##*/} - La fecha de novedad para gestion $codgestion debe ser anterior a hoy"
    else
      logInfo "Rechazado ${1##*/} - Fecha no corresponde a Gestion"
    fi
		return 1
	else
    return 0
    
fi
}	
	  
function verificar_FECHA(){
	
if [ $2 -le $1 -a $1 -le $3 ]
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
	logInfo  "Aceptado ${1##*/} - Destino $ACEPDIR/$codgestion/${1##*/}"
	mover.sh $1 $ACEPDIR/$codgestion RecPro
	return 0	
}

function rechazarArchivo(){
	
	logInfo "Movido ${1##*/} - Destino $RECHDIR/${1##*/}"
	mover.sh  $1 $RECHDIR RecPro
	return 0
}

# Si existen archivos en los subdirectorios de ACEPDIR se intenta 
# invocar el comando ProPro
# Si se pudo invocar se graba en LOG: ProPro - Corriendo  <Id>
# Si hay archivos pero esta corriendo se graba en LOG: Posponer a siguiente Ciclo
# Si surge algun error se muestra por pantalla

function novedadesPedientes(){
	
if hayNovedadesPendientes $ACEPDIR;
	then
	PID=$(getPid ProPro)
	
	if [ "$PID" = "" ]; 
	then
		Start.sh ProPro RecPro
		#PID=$(getPid ProPro)
		#logInfo "ProPro corriendo bajo el no.: $PID"
		return 0
	else
		logInfo "Invocacion de ProPro propuesta para el siguiente ciclo $PID"
		return 0
	fi
fi
return 0	
}

function hayNovedadesPendientes(){
  if [ "$(ls -A $1)" ]
  then
    for directorio in $1
     do		
      local dir=`find $directorio -type f | wc -l`
	    if [ ! $dir -eq 0 ]
	    then
		    return 0
	    fi
    done
  fi
  return 1
}

function getPid(){
    local ppid=`ps aux | grep "\($BINDIR\)\?/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    echo $ppid
}
