#!/bin/bash -x

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
#																	   #
########################################################################
#       															   #
# FUNCION                     		                                   #
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

MAEDIR=mae
NOVEDIR=novedades
ACEPDIR=a_protocolarizar
RECHDIR=rechazados
LOGDIR=log
SLEEP_TIME=$1
nroCiclo=0

#Valido si el fue ambiente inicializado correctamente
if [-n "$INI"] # ambiente correcto, $VAL con valor 0
	then
		logInfo "Iniciado Demonio - Ciclo: $nroCiclo" "INFO"
		while [[ true ]]; do
			procesarArchivos
			let nroCiclo++
			logInfo "Dormir Demonio" "INFO"
			sleep $SLEEP_TIME
			logInfo "Desperto Demonio - Ciclo: $nroCiclo" "INFO"
		done 
	else
		logError "El ambiente no se inicializo correctamente" "ERR"
		logError "No es posible su ejecucion" "ERR"
		Exit 1
fi 
