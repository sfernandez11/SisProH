#!/bin/bash -x
source RecFunctions.sh

NOVEDIR=~/TPSO/SisProH/NOVEDIR/*
RECHDIR=~/TPSO/SisProH/RECHDIR/*

#http://blackshell.usebox.net/pub/shell/taller_sh/x137.html

for file in $NOVEDIR
do
	if VerificarTipo "$file";
	then 
		if VerificarFormato "$file";
		then 
			if verificarCOD_GESTION "$file";
			then
				if verificarCOD_NORMA "$file";
				then
					if verificarCOD_EMISOR "$file";
					then
						if verificar_FECHA_GESTION "$file";
						then
							echo "CAMINO FELIZ"
							#aceptarArchivo $file
						else
							echo "escribir log"
						fi	
					else
						echo "escribir log"
					fi	
				else
					echo "escribir log"
				fi	
			else	
				echo "escribir log"		
			fi
		else
			echo "escribir log"
		fi
	else
		echo "escribir log"
	fi		
done 
