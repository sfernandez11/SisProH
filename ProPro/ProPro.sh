#!/bin/bash

sh ../glog.sh ProPro 'mensaje de prueba' INFO
AUX= ls 'PROCDIR/' | grep teto
if [ -a PROCDIR/teto.test ]
then
	echo 'existe'
fi
