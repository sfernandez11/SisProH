#!/bin/bash

# Script a cargo de comenzar la ejecución del demonio
#-----------------------------------------------------------------------------------------------------------
# Ejecutar de esta forma:
# >$ ./Start.sh
#------------------------------------------------------------------------------------------------------------

source IniFunctions.sh

if ambienteVacio; then 
	echo "Ambiente no inicializado. Ejecute IniPro"
	echo "No se realizó ninguna acción"
	return 1
fi


if $(pgrep RecPro.sh); then
    echo "El demonio ya se encuentra inicializado, no se realizó ninguna acción"
    return 1
fi

echo "El demonio se está ejecutando" 

#nohup feponio.sh > /dev/null 2>&1 &

return 0


