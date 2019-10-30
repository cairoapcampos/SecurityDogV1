#!/bin/bash

cat erlangen.rou.xml | grep depart | awk '{print $3}' | cut -d'"' -f2 > timeCar.txt

max=480
cont=1
zeros=".00"

while read line
do

lineInt=${line%.*} #Converte float para um int

if [ $lineInt -ge $max ]
then
     dtime=$cont$zeros
     sed -i "s/depart=\"$line\"/depart=\"$dtime\"/" erlangen.rou.xml
     echo "depart=\"$line\" alterado para depart=\"$dtime\""
     let cont=cont+1
fi

done < timeCar.txt
