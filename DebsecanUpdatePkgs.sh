#!/bin/bash

dt=$(date +%d%m%y_%H%M)
codename=$(lsb_release -c | tr -s '[:space:]' ' ' | cut -d ' ' -f2)
ctvulpkg=$(debsecan --suite $codename --only-fixed --format packages | wc -l)

if [ $ctvulpkg -gt 0 ]
then
    echo
    debsecan --suite $codename --only-fixed | tee Reports/VulnerableUpdatePkgs_$dt.txt
    apt install $(debsecan --suite $codename --only-fixed --format packages)
else
    echo
    echo "Não existe pacotes com correções de vulnerabilidade disponiveis!" > Reports/VulnerableUpdatePkgs_$dt.txt
fi

hlpkg=$(apt list --upgradable 2> /dev/null | grep / | cut -f 1 -d/ | wc -l)

if [ $hlpkg -gt 0 ]
then
echo
echo "O(s) seguinte(s) pacote(s) não vulneraveis possue(m) atualização(ões): "
echo
apt list --upgradable 2> /dev/null | grep / | cut -f 1 -d/
echo
NewHlPKG
else
echo
echo  "Não existe pacotes para serem atualizados!" > Reports/NormalUpdatePkgs_$dt.txt
fi
