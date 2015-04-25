#!/bin/bash 
########################################################################
#                                                                      #
# Funciones usadas para la Recepcion de Documentos (RecPro)            #
#                                                                      #
########################################################################


#VERIFICA ARCHIVOS QUE SEAN SOLO DE TEXTO

function VerificarTipo(){	
	
local tipe=`file $1`	

if !(echo $tipe | grep '.*text$' &>/dev/null) 
	then 
		#../mover.sh $1 "$HOME/Tp"
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
		return 1
	else
		return 0
fi
}
		
#VERIFICA ARCHIVOS TENGAN COD_GESTION EN MAESTRO 

function verificarCOD_GESTION(){
		
local codgestion=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\1/g'`

if !(grep "^$codgestion;.*;.*;.*;" "$HOME/Tp/mae.txt" &>/dev/null)
	then 
		#../mover.sh $1 "$RECHDIR"
		return 1
	else
		return 0
fi		     
}
	

#VERIFICA ARCHIVOS TENGAN COD_NORMA EN MAESTRO

function verificarCOD_NORMA(){
	
local codnorma=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\2/g'`

if !(grep "^$codnorma;.*;" "$HOME/Tp/mae.txt" &>/dev/null)
	then 
		#../mover.sh $1 "$RECHDIR"
		return 1
	else
		return 0 
fi	
}
	

#VERIFICA ARCHIVOS TENGAN COD_EMISOR EN MAESTRO

function verificarCOD_EMISOR(){
	
local codemisor=`echo ${1##*/} | sed 's/^\(.*\)_\(.*\)_\(.*\)_\(.*\)_\(.*\)/\3/g'`

if !(grep "^$codemisor;.*;.*;" "$HOME/Tp/mae.txt" &>/dev/null)
	then 
		#../mover.sh $1 "$RECHDIR"
		return 1
	else
		return 0
fi			
}		

# Verifica la  FECHA

function verificarFECHA(){
	
if echo $tipo &>/dev/null;
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
	#../mover.sh $file "$ACEPDIR"
	echo $1	
	
}


