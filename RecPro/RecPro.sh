#!/bin/bash 
FILE=./NOVEDIR
if [ -d "$FILE" ] 
then
echo "EXiste NOVEDIR"
else
echo "No Existe NOVEDIR"
fi
du -s "$FILE"
DIR="$FILE/*"

#if [ "$(ls -A $DIR)" ]
#then
#echo $DIR
#if

for f in $DIR
do
echo $f
done 

