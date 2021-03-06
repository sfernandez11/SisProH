#!/bin/bash

[ -d grupo02 ] && rm -r grupo02
[ -f grupo02.tar.gz ] && rm -r grupo02.tar.gz

mkdir grupo02
[ $? ] && echo Dir grupo02 creado || echo Error al crear grupo02
mkdir grupo02/conf
[ $? ] && echo Dir conf creado || echo Error al crear conf
cp -r ProPro grupo02/ProPro
cp -r RecPro grupo02/RecPro
cp -r InfPro grupo02/InfPro
cp -r pruebas grupo02/pruebas
cp -r Datos grupo02/Datos
cp -r ArchivosCaminoFeliz grupo02/ArchivosCaminoFeliz

echo
echo Directorios copiados .. 
echo
echo Copiando archivos  .. 

echo el script es $0

for file in $PWD/*.sh ;
do
  #echo Arch ${file##*/} script ${0##*/}
  if [ ${file##*/} == "InsPro.sh" ]
  then
    continue
  fi
  if [ ! ${file##*/} == ${0##*/} ]
  then
    cp "${file##*/}" grupo02
  fi
done

cp Readme.txt grupo02/Readme.txt

echo
echo Aplicando patch a InsPro.sh . . . 
echo

grep -v '# REMOVE$' InsPro.sh | sed 's-GRUPO=$PWD/grupo02-GRUPO=$PWD-' >> grupo02/InsPro.sh
chmod +x grupo02/InsPro.sh

echo
echo Comprimiendo . . . 
echo

tar -zcf grupo02.tar.gz grupo02

echo
echo Borrando carpeta temporal . . . 
echo

rm -r grupo02

#echo
#echo Descomprimiendo tar ...  
#echo

#tar -zxf grupo02.tar.gz
