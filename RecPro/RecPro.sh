#!/bin/bash

########################################################################
#                                                                      #
#  Comando para la Recepcion de Documentos (RecPro.sh) tipo Demonio    #
#                                                                      #
########################################################################
#                                                                      #
# PARAMETROS                                                           #
# Parametro $1 (obligatorio): SLEEP_TIME                               #
#                                                                      #
########################################################################
#                                                                      #
# PRE-CONDICIONES                                                      #
# No se ejecuta si la inicializacion del ambiente no fue realizada     #
#                                                                      #
########################################################################
#                                                                      #
# FUNCION                                                              #
# Verifica si el directio NOVEDIR tiene archivos a procesar            #
# 	Si hay verifica si es correcto                                     #
# 		-Si es correcto lo mueve al directorio ACEPDIR                 #
#       	-si el directorio no existe lo crea                        #
#		-Sino lo rechaza colocandolo el el directorio RECHDIR          #
#                                                                      #
# Verifica si el directorio ACEPDIR tiene archivos a procesar          #
# 	Si hay intenta arrancar el comando ProPro                          #
#                                                                      #
# Duerme un tiempo y vuelve a empezar salvo que se lo detenga con STOP #
#   Mantener contador de ciclos de ejecucion                           #
#                                                                      #
########################################################################
source RecFunctions.sh

SLEEP_TIME=20
nroCiclo=0
INI=0


#Valido si el ambiente fue inicializado correctamente
if [ -n $INI ] # ambiente correcto, $VAL con valor 0
	then
		while [[ true ]]; do
		    logInfo "Demonio despierto - Ciclo: $nroCiclo"
			procesarNovedades
			novedadesPedientes
			let nroCiclo++
			logInfo "Demonio dormir"
			sleep $SLEEP_TIME	
		done 
	else
		logError "El ambiente no se inicializo correctamente"
		logError "No es posible su ejecucion"
		exit 1
fi 
