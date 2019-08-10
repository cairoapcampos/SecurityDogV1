#!/bin/bash

######################################################
# Script de Hardening                                #
# Versão: 1.0 (Codinome: Laika)                      #
# Autor: Cairo Ap. Campos                            #
######################################################

clear

## Verifica se o usuário que executou o script é root
if [ "$USER" != "root" ]
then
      echo
      echo "Permissão negada! Por favor execute SecurityDog como root."
      echo
      exit
fi

## Menu de escolha de funções de hardening ##
menu() {
   cat logo.txt
   echo "#############################################################################"
   echo "######                       Opções de Hardening                       ######"
   echo "#############################################################################"
   echo "###  1 - Atualizar lista de pacotes e instalar pacotes para o hardening   ###"
   echo "###  2 - Atualizar pacotes que possuem vulnerabilidades                   ###"
   echo "###  3 - Desabilitar CTRL + ALT + DEL                                     ###"
   echo "###  4 - Habilitar tempo de logout para terminal ocioso                   ###"
   echo "###  5 - Desabilitar terminais para impedir o login de Root               ###"
   echo "###  6 - Desabilitar Shell de usuários/serviços que não fazem login       ###"
   echo "###  7 - Habilitar grupo que pode usar o comando su                       ###"
   echo "###  8 - Remover Suid bit de comandos                                     ###"
   echo "###  9 - Configurar SSH                                                  ###"
   echo "###  10 - Configuração de Banner                                          ###"
   echo "###  11 - Configurar Fail2ban                                             ###"
   echo "###  12 - Analisar o sistema em busca de Rootkits                         ###"
   echo "###  13 - Remover pacotes desnecessários                                  ###"
   echo "###  14 - Verificar duplicidade de ID do Root                             ###"
   echo "###  15 - Proteger partições listadas em /etc/fstab                       ###"
   echo "###  16 - Iniciar todas as configurações                                   ###"
   echo "###  0 - Sair                                                             ###"
   echo "#############################################################################"
   echo
   echo -n "Escolha uma das opções acima: "
   read opmenu
   case $opmenu in
       1) PKGSRT ;;
       2) UpdatePKGRT ;;
       3) DisKeysRT ;;
       4) LgtTermRT ;;
       5) DisTermRootRT ;;
       6) DisShellRT ;;
       7) GrpPAMRT ;;
       8) DisSUIDRT ;;
       9) ConfigSSHRT ;;
       10) EdiMotdIssueRT ;;
       11) Fail2banRT ;;
       12) RkhRT ;;
       13) RmPKGRT ;;
       14) RtIDRT ;;
       15) EditFstabRT;;
       16) StartAllOptions ;;
       0) exit ;;
       *) echo " "
          echo "Opção Invalida! Retornando ao Menu..."
          sleep 3
          clear
          menu ;;
   esac

}

#######################################################################################
###  Fuções sem retorno para o menu principal usadas pela a função StartAllOptions  ###
#######################################################################################

## 1. Atulizar lista de pacotes disponiveis e instala pacotes necessários para o harderning ##

PKGS() {
   echo
   echo "#############################################################################"
   echo "######     Escolha de pacotes a serem instalados para o Hardening      ######"
   echo "#############################################################################"
   echo "### 1 - Instalar todos os pacotes                                         ###"
   echo "### 2 - Instalar Debsecan                                                 ###"
   echo "### 3 - Instalar Fail2Ban                                                 ###"
   echo "### 4 - Instalar Rkhunter                                                 ###"
   echo "### 5 - Instalar Htop                                                     ###"
   echo "### 0 - Retornar para o menu principal                                    ###"
   echo "#############################################################################"
   echo
   echo -n "Escolha uma opção: "
   read oppkgs
   case $oppkgs in
       1) InstallAllPKGS ;;
       2) InstallDebsecan ;;
       3) InstallF2B ;;
       4) InstallRkh ;;
       5) InstallHtop ;;
       0) menu ;;
       *) echo " "
          echo "Opção Invalida! Retornando para o menu de pacotes..."
          sleep 3
          clear
          PKGS ;;
   esac
}

## 2. Atualiza pacotes e agenda tarefa de atualização no Cron ##
UpdatePKG() {

findbin=$(which debsecan | wc -l)

if [ $findbin -eq 0 ]
then 
    echo
    echo "O pacote Debsecan não está instalado!"
    sleep 3
    echo
    echo "Instalando pacote... "
    sleep 3
    echo
    apt update && apt install -y debsecan
    UpdatePKG
else
    CronRule

    dt=$(date +%d%m%y_%H%M)
    codename=$(lsb_release -c | tr -s '[:space:]' ' ' | cut -d ' ' -f2)
    ctvulpkg=$(debsecan --suite $codename --only-fixed --format packages | wc -l)

    if [ $ctvulpkg -gt 0 ]
    then
        echo
        echo "Os seguintes pacotes possuem vulnerabilidades de segurança: "
        sleep 3
        echo
        debsecan --suite $codename --only-fixed | tee Reports/VulnerableUpdatePkgs_$dt.txt
        echo
        echo "Atualizando pacotes vulneraveis: "
        sleep 3
        echo
        apt install $(debsecan --suite $codename --only-fixed --format packages)
     else
        echo
        echo "Não existe pacotes com correções de vulnerabilidade disponiveis!" | tee Reports/VulnerableUpdatePkgs_$dt.txt
        sleep 3
     fi

     hlpkg=$(apt list --upgradable 2> /dev/null | grep / | cut -f 1 -d/ | wc -l)

     if [ $hlpkg -gt 0 ]
     then
         echo
         echo "O(s) seguinte(s) pacote(s) não vulneraveis possue(m) atualização(ões): "
         sleep 3
         echo
         apt list --upgradable 2> /dev/null | grep / | cut -f 1 -d/ | tee Reports/NormalUpdatePkgs_$dt.txt
         echo
         NewHlPKG
     else
         echo
         echo  "Não existe pacotes não vulneraveis para serem atualizados!" | tee Reports/NormalUpdatePkgs_$dt.txt
         sleep 3
     fi
fi

}

## 3. Desabilitar CTRL+ALT+DEL ##
DisKeys() {
echo
systemctl mask ctrl-alt-del.target
systemctl daemon-reload
echo
echo "Reboot via teclas CTRL+ALT+DEL desativado com sucesso!"
sleep 3
}

## 4. Logout automático do terminal após quantidade de minutos de inatividade ##
LgtTerm() {

echo
echo -n  "Digite o tempo de inatividade tolerado para logout automático (Digitar tempo em minutos): "
read tmplgt
calctmp=$((tmplgt*60))


tmft=$(cat /etc/profile | grep TMOUT | wc -l)
segtmft=$(cat /etc/profile | grep TMOUT | cut -d= -f2)

if [ $tmft -eq 0 ]
then
    echo " " >> /etc/profile
    echo "### Logout automático ###" >> /etc/profile
    echo "export TMOUT=$calctmp" >> /etc/profile
    source /etc/profile
    echo
    echo "O tempo de $tmplgt minutos, foi definido com sucesso!"
    sleep 3
elif [ $segtmft = $calctmp ]
then
    echo
    echo "O Tempo de logout é o mesmo já definido!"
    sleep 3
else
    echo
    sed -i "s/export TMOUT.*/export TMOUT=$calctmp/" /etc/profile
    mintmft=$((segtmft/60))
    echo "O Tempo de logout foi atualizado de $mintmft minutos para $tmplgt minutos"
    sleep 3
fi
}

## 5. Desabilita login direto do root nos terminais de texto (tty) do servidor ##
DisTermRoot() {
echo
for i in $(seq 12);
do
ntty=$(echo "tty$i")
ctty=$(echo "#tty$i")
sed -i "/$ntty/{ s/$ntty/$ctty/;:a;n;ba }" /etc/securetty
done
echo "Terminais desabilitados (tty1 à tty12) para o login do Root! "
sleep 3
}

## 6. Remover shell válidas de usuarios que não precisam fazer login ##
DisShell() {

cp /etc/passwd /etc/passwd.old

dts=$(date +%d%m%y_%H%M)
hmusr=$(ls /home/ | grep -v lost+found)
vldusr=$(echo "root" && echo "$hmusr")

echo "$vldusr" > vldusr.txt

cat /etc/passwd | grep -v /bin/false | grep -v /sbin/nologin | grep -v /bin/sync | cut -f 1 -d: > gnusr.txt

while read line
do
sed -i "/$line/d" gnusr.txt
done < vldusr.txt

usrshell=$(cat gnusr.txt | wc -l)

if [ $usrshell -gt 0 ]
then

   echo
   echo "Verificando usuários que possuem shell habilitada..."
   sleep 3
   echo

   while read line2
   do
   usermod -s /bin/false $line2
   echo "Shell removida de: $line2" | tee -a Reports/UserShells_$dts.txt
   sleep 3
   echo
   done < gnusr.txt

else
   echo
   echo "Não há usuários com shells mal configuradas!" | tee Reports/UserShells_$dts.txt
   sleep 3
fi

rm gnusr.txt vldusr.txt
}

## 7. Habilita no PAM o grupo que pode utilizar o comando su ##
GrpPAM() {

AddGrp

cp /etc/pam.d/su /etc/pam.d/su.old

pamline=$(cat /etc/pam.d/su | grep "# auth       required   pam_wheel.so" | grep -v group=nosu | wc -l)

if [ $pamline -eq 1 ]
then
    sed -i "/#.*pam_wheel.so/{ s/#.*pam_wheel.so/auth required pam_wheel.so group=$gname/;:a;n;ba }" /etc/pam.d/su
    echo
    echo "O grupo $gname foi habilitado para usar o su!"
    sleep 3
else
     
     vlgrpln=$(cat /etc/pam.d/su | grep "auth required pam_wheel.so group=")
     vlgrp=$(cat /etc/pam.d/su | grep "auth required pam_wheel.so group=" | cut -d= -f2)
     
     sed -i "s/$vlgrpln/auth required pam_wheel.so group=$gname/" /etc/pam.d/su
     echo
     echo "O grupo foi alterado de $vlgrp para $gname!"
     sleep 3
fi

sed -i -r 's/^#(.*SULOG_FILE.*)$/\1/' /etc/login.defs
touch /var/log/sulog
echo
echo "Para visualizar logs da utilização do comando su, utilize o arquivo /var/log/sulog."
sleep 5
}

## 8. Remover Suid bit de comandos ##
DisSUID() {
echo
echo "O Suid bit foi removido dos seguintes comandos: "
sleep 3
echo
for sbcmd in $(find / -perm -4000 2> /dev/null | grep -v /bin/su | grep -v /usr/bin/passwd)
do
chmod -s $sbcmd
echo "$sbcmd"
done
}

## 9. Configuração do SSH ##
ConfigSSH() {

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old

GNSSH
PORTSSH
GRPSSH
IPSSH
TCPWP
systemctl restart ssh.service
echo
echo "Caso seja necessário fazer alterações posteriores, basta editar o arquivo /etc/ssh/sshd_config"
sleep 5
}

## 10. Configura os arquivos Motd e Issue.net do banner ##
EdiMotdIssue() {
echo
echo "Desabilitando a mensagem de caixa de e-mail no login... "
sleep 3
sed  -i "s/session    optional     pam_mail.so/#session    optional     pam_mail.so/" /etc/pam.d/sshd
echo
echo "Habilitando no arquivo /etc/ssh/sshd_config o issue.net... "
sleep 3
sed -i 's/#Banner.*none/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
echo
echo "Desabilitando no arquivo /etc/ssh/sshd_config a mensagem de último login... "
sleep 3
sed -i 's/#PrintLastLog yes/PrintLastLog no/' /etc/ssh/sshd_config
echo
echo "Desabilitando antigos arquivos do motd... "
sleep 3
chmod -x /etc/update-motd.d/10-uname
mv /etc/update-motd.d/10-uname /etc/update-motd.d/10-uname.old
mv /etc/motd /etc/motd.old
mv /etc/issue /etc/issue.old
mv /etc/issue.net /etc/issue.net.old
CPBANNER
}

## 11. Configuração do Fail2ban ##
Fail2ban() {

findbin2=$(which fail2ban-server | wc -l)

if [ $findbin2 -eq 0 ]
then 
    echo
    echo "O pacote Fail2Ban não está instalado!"
    sleep 3
    echo
    echo "Instalando pacote... "
    sleep 3
    echo
    apt update && apt install -y fail2ban
    Fail2ban
else

   cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

   echo
   echo -n "Você deseja alterar as configurações padrão do Fail2ban? [s/n]: "
   read f2b

   if [ $f2b = "s" ]
   then
       echo
       echo -n "Defina endereços IP's que não serão bloqueados utilizando espaços (Ex: 192.168.0.29 192.168.1.0/24): "
       read ips
       rips=$(echo "$ips" | sed 's/\//\\\//g')
       sed -i "s/ignoreip.*127.0.0.1\/8/ignoreip = 127.0.0.1\/8 $rips/" /etc/fail2ban/jail.local #Debian 9
       sed -i "s/#ignoreip.*::1/ignoreip = 127.0.0.1\/8 ::1 $rips/" /etc/fail2ban/jail.local #Debian 10
       echo
       
       echo -n "Digite o tempo que o IP ficará banido ou bloqueado (Digitar tempo em minutos): "
       read tmpban
       ctmpban=$((tmpban*60))
       sed -i "s/bantime.*600/bantime = $ctmpban/" /etc/fail2ban/jail.local #Debian 9
       sed -i "s/bantime.*10m/bantime = $ctmpban/" /etc/fail2ban/jail.local #Debian 10
       echo
       
       echo -n "Digite o numero máximo de tentaivas de login até um ip ser bloqueado: "
       read  attlogin
       sed -i "s/maxretry.*5/maxretry = $attlogin/" /etc/fail2ban/jail.local #Debian 9 e 10
       
       F2bPort
       echo
       echo "Reiniciando serviços do SSH e Fail2ban..."
       sleep 3
       systemctl restart ssh.service
       systemctl restart fail2ban.service
       echo
       
       echo "Ok.Serviços reiniciados!"
       sleep 3
       echo
       
       echo "Serviços monitorados pelo Fail2Ban: "
       sleep 3
       echo
       fail2ban-client status
   
   elif [ $f2b = "n" ]
   then
   
       F2bPort
       echo
       echo "Reiniciando serviços do SSH e Fail2ban..."
       sleep 3
       systemctl restart ssh.service
       systemctl restart fail2ban.service
       echo
       
       echo "Ok.Serviços reiniciados!"
       sleep 3
       echo
       
       echo "Serviços monitorados pelo Fail2Ban: "
       sleep 3
       echo
       fail2ban-client status
       
       echo
       echo "As demais configurações padrão serão mantidas!"
       sleep 3
       echo
       
       echo "Caso seja necessário fazer alterações posteriores, basta editar o arquivo /etc/fail2ban/jail.local"
       sleep 3    
      
       else
       echo
       echo "Opção errada!"
       sleep 3
       Fail2ban
   fi
fi

}

## 12. Instala, configura e executa o Rkhunter ##
Rkh() {

findbin3=$(which rkhunter | wc -l)

if [ $findbin3 -eq 0 ]
then 
    echo
    echo "O pacote Rkhunter não está instalado!"
    sleep 3
    echo
    echo "Instalando pacote... "
    sleep 3
    echo
    apt update && apt install -y rkhunter
    #clear
    Rkh
else
    sed -i 's/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf
    sed -i 's/MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf
    sed -i 's/WEB_CMD="\/bin\/false"/WEB_CMD=""/' /etc/rkhunter.conf
    sed -i 's/CRON_DAILY_RUN=""/CRON_DAILY_RUN="true"/' /etc/default/rkhunter
    sed -i 's/CRON_DB_UPDATE=""/CRON_DB_UPDATE="true"/' /etc/default/rkhunter

    echo
    echo "Verificando a versão instalada: "
    sleep 5
    echo
    rkhunter --versioncheck
    echo
    echo "Atualizando assinaturas de rootkits: "
    sleep 5
    echo
    rkhunter --update
    echo
    echo "Atualizando as propriedades dos arquivos: "
    sleep 5
    echo
    rkhunter --propupd
    echo
    echo "Verificando o sistema: "
    sleep 5
    echo
    rkhunter --check --sk
fi

}

## 13. Remove pacotes desnecessários da instalação padrão  ##
RmPKG() {
echo
echo "Removendo pacotes desnecessários: "
sleep 3
echo
apt purge -y bluez bluetooth crda iw libiw30:amd64 wireless-regdb wireless-tools wpasupplicant 
apt purge -y netcat-traditional telnet wget git
apt autoremove -y
apt clean
}

## 14. Verifica a duplicidade de ID do Root  ##
RtID() {

idroot=$(cat /etc/passwd | grep :0: | wc -l)
userid=$(cat /etc/passwd | grep :0: | cut -f 1 -d:)
infoid=$(cat /etc/passwd | grep :0:)

if [ $idroot -gt 1 ]
then
    echo
    echo "Existe mais de um usuário com o ID 0. Somente o Root pode ter esse ID!: "
    echo
    echo "Os usuários de ID's duplicados são: "
    sleep 3
    echo
    echo "$userid"
    echo
    echo "Configuração em /etc/passwd: "
    sleep 3
    echo
    echo "$infoid"
    sleep 3
else
    echo
    echo "O usuário com o ID 0 é o: $userid"
    sleep 3
    echo
    echo "Configuração em /etc/passwd: "
    sleep 3
    echo
    echo "$infoid"
    sleep 3
fi
}

## 15. Protege partições listadas no arquivo /etc/fstab   ##
EditFstab(){

cp /etc/fstab /etc/fstab.old

boot="defaults,nosuid 0 2"
bar="defaults 0 1"
home="defaults,nosuid,noexec,nodev 0 2"
tmp="defaults,nosuid,noexec,nodev 0 2"
var="defaults,nosuid,noexec,nodev 0 2"
var_log="defaults,nosuid,noexec,noatime,nodev 0 2"

cat /etc/fstab | grep -v "#" | grep -v swap | grep UUID > clFstab.txt

while read line
do
a=$(echo "$line" | awk '{print $1}')
b=$(echo "$line" | awk '{print $2}')
c=$(echo "$line" | awk '{print $3}')
   if [ $b = "/boot" ]
   then
   b="\/boot"
   new_boot=$(echo "$a $b $c $boot")
   sed -i 's/'"$a.*"'/'"$new_boot"'/' /etc/fstab
   elif [ $b = "/" ]
   then
   b="\/"
   new_bar=$(echo "$a $b $c $bar")
   sed -i 's/'"$a.*"'/'"$new_bar"'/' /etc/fstab
   elif [ $b = "/home" ]
   then
   b="\/home"
   new_home=$(echo "$a $b $c $home")
   sed -i 's/'"$a.*"'/'"$new_home"'/' /etc/fstab
   elif [ $b = "/tmp" ]
   then
   b="\/tmp"
   new_tmp=$(echo "$a $b $c $tmp")
   sed -i 's/'"$a.*"'/'"$new_tmp"'/' /etc/fstab
   elif [ $b = "/var" ]
   then
   b="\/var"
   new_var=$(echo "$a $b $c $var")
   sed -i 's/'"$a.*"'/'"$new_var"'/' /etc/fstab
   elif [ $b = "/var/log" ]
   then
   b="\/var\/log"
   new_var_log=$(echo "$a $b $c $var_log")
   sed -i 's/'"$a.*"'/'"$new_var_log"'/' /etc/fstab
   else
   echo "Partição Desconhecida!"
   sleep 3
   fi
done < clFstab.txt

FSTReboot

}

# 16. Inicia todas as opções
StartAllOptions() {
clear
cat logo.txt
echo "############################################################################"
echo "###  Atualizando lista de pacotes e instala pacotes para o hardening     ###"
echo "############################################################################"
PKGS
echo
echo "############################################################################"
echo "###          Atualizando pacotes que possuem vulnerabilidades            ###"
echo "############################################################################"
UpdatePKG
echo
echo "############################################################################"
echo "###                 Desabilitando CTRL + ALT + DEL                       ###"
echo "############################################################################"
DisKeys
echo
echo "############################################################################"
echo "###          Habilitando tempo de logout para terminal ocioso            ###"
echo "############################################################################"
LgtTerm
echo
echo "############################################################################"
echo "###             Desabilitando login do Root no terminal físico           ###"
echo "############################################################################"
DisTermRoot
echo
echo "############################################################################"
echo "###    Desabilitando shell de usuários/serviços que não fazen login      ###"
echo "############################################################################"
DisShell
echo
echo "############################################################################"
echo "###              Habilitando grupo que pode usar o comando su            ###"
echo "############################################################################"
GrpPAM
echo
echo "############################################################################"
echo "###                    Removendo suid bit de comandos                    ###"
echo "############################################################################"
DisSUID
echo
echo "############################################################################"
echo "###                          Configurando SSH                            ###"
echo "############################################################################"
ConfigSSH
echo
echo "############################################################################"
echo "###                          Configurando Banner                         ###"
echo "############################################################################"
EdiMotdIssue
echo
echo "############################################################################"
echo "###                          Configurando o Fail2ban                     ###"
echo "############################################################################"
Fail2ban
echo
echo "############################################################################"
echo "###           Rkhunter - Analisa o sistema em busca de rootkits          ###"
echo "############################################################################"
Rkh
echo
echo "############################################################################"
echo "###                    Removendo pacotes desnecessários                  ###"
echo "############################################################################"
RmPKG
echo
echo "############################################################################"
echo "###                    Verificando duplicidade de ID do Root             ###"
echo "############################################################################"
RtID
echo
echo "############################################################################"
echo "###                Protegendo partições listadas em /etc/fstab           ###"
echo "############################################################################"
EditFstab
RtMenu
}

###########################
### Funções especificas ###
###########################

InstallOthPKGS(){

echo
echo -n "Você deseja instalar outro pacote? [s/n]: "
read othpkg

if [ $othpkg = "s" ]
then
PKGS
elif [ $othpkg = "n" ]
then
    echo
    echo "Ok. Nenhum outro pacote será instalado! "
    sleep 3 
else
    echo
    echo "Opção errada!"
    sleep 3
    PKGS
fi
}

InstallAllPKGS() {
echo
apt update && apt install -y debsecan fail2ban htop rkhunter
}

InstallDebsecan() {
echo
apt update && apt install -y debsecan
InstallOthPKGS
}

InstallF2B() {
echo
apt update && apt install -y fail2ban
InstallOthPKGS
}

InstallRkh() {
echo
apt update && apt install -y rkhunter
InstallOthPKGS
}

InstallHtop() {
echo
apt update && apt install -y htop
InstallOthPKGS
}

CronRule(){
echo "##### Regra para atualizar pacotes #####" > jobs.txt
echo "00 00 * * 6 bash /root/SecurityDogV1/DebsecanUpdatePkgs.sh" >> jobs.txt
crontab jobs.txt
rm jobs.txt
}

NewHlPKG() {
echo -n "Deseja atualizá-lo(s) [s/n] ?: "
read newhlpkg
if [ $newhlpkg = "s" ]
then
echo
echo "Atualizando o(s) pacote(s): "
echo
apt install $(apt list --upgradable 2> /dev/null | grep / | cut -f 1 -d/)
elif [ $newhlpkg = "n" ]
then
echo
echo "O(s) pacote(s) não será(ão) atualizado(s)!"
else
echo
echo "Opção errada!"
echo
sleep 3
NewHlPKG
fi
}

AddGrp(){
echo
echo -n  "Digite um nome para o grupo: "
read gname
fgroup=$(cat /etc/group | cut -f 1 -d: | grep $gname | wc -l)

if [ $fgroup -eq 0 ]
then
    groupadd $gname
    echo
    echo  "O grupo $gname foi inserido com sucesso!"
else
    echo
    echo "O grupo $gname já existe!"
fi

ls /home/ | grep -v lost+found > usrpam.txt

while read lineusr
do
echo
addgroup $lineusr $gname
done < usrpam.txt

rm usrpam.txt
}

GNSSH() {
sed -i 's/#.*prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/" /etc/ssh/sshd_config
echo
echo "As configurações básicas foram definidas com sucesso!"
}

PORTSSH() {
stsshport=$(cat /etc/ssh/sshd_config | grep "#Port 22" | wc -l)

if [ $stsshport -eq 1 ]
then 
   echo
   echo -n "Por motivos de segurança, você deseja mudar a porta 22 padrão do SSH? [s/n]: "
   read opport

   if [ $opport = "s" ]
   then
       echo
       echo -n "Digite um numero de porta: "
       read newport
       sed -i "s/#Port 22/Port $newport/" /etc/ssh/sshd_config
       echo
       echo "A porta foi alterada para $newport!"
   elif [ $opport = "n" ]
   then
      sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
      echo
      echo "A porta 22 foi habilitada!"
   else
      echo
      echo "Opção errada!"
      PORTSSH
   fi

else
      diffsshport=$(cat /etc/ssh/sshd_config | grep -v "#" | grep -E 'Port ?' | cut -d" " -f2)
      echo
      echo -n "A porta do SSH está definida como  $diffsshport, deseja alterá-la? [s/n]: "
      read opport

      if [ $opport = "s" ]
      then
          echo
          echo -n "Digite um numero de porta: "
          read newport
          sed -i "s/Port $diffsshport/Port $newport/" /etc/ssh/sshd_config
          echo
          echo "A porta foi alterada para $newport!"
        
      elif [ $opport = "n" ]
      then
         echo
	     echo "Ok. A porta não será alterada!"
      else
         echo
         echo "Opção errada!"
         PORTSSH
      fi
fi
}

GRPSSH() {
echo
echo -n "Você deseja criar um grupo para usuários que poderão fazer login no SSH? [s/n]: "
read opgpssh

if [ $opgpssh = "s" ]
then
    
    AddGrp

    sshdgrpln=$(cat /etc/ssh/sshd_config | grep AllowGroups | cut -f 2 -d" " | wc -l)
    sshdgrp=$(cat /etc/ssh/sshd_config | grep AllowGroups | cut -f 2 -d" ")

      if [ $sshdgrpln -eq 0 ]
      then
          echo " " >> /etc/ssh/sshd_config
          echo "# Additional Settings" >> /etc/ssh/sshd_config
          echo "AllowGroups $gname " >> /etc/ssh/sshd_config
          echo
          echo "O grupo $gname foi habilitado para usar o ssh!"
       elif [ $sshdgrp = $gname ]
       then
           echo
           echo "O grupo $gname já foi definido anteriormente!"
       else  
           echo
           sed -i "s/AllowGroups.*/AllowGroups $gname/" /etc/ssh/sshd_config
           echo " O grupo $sshdgrp anteriormente habilitado para usar o ssh, foi subistituido por $gname!"
       fi

elif [ $opgpssh = "n" ]
then
    echo
    echo "OK. Nenhum grupo será definido!"
 else
    echo
    echo "Opção errada!"
    GRPSSH
  fi
}

IPSSH() {
echo
echo -n "Você deseja definir uma interface de rede do servidor para a conexão SSH? [s/n]: "
read opintssh

if [ $opintssh = "s" ]
then
    echo
    echo "Listando interfaces de rede: "
    echo
    ip a
    echo
    echo -n "Escolha um endereço IP de uma das interfaces acima para conectar ao SSH: "
    read opipnow

    listenip=$(cat /etc/ssh/sshd_config | grep -v "#" | grep ListenAddress | cut -f 2 -d" ")

     if [ -z $listenip ]
     then
         echo
         echo "ListenAddress $opipnow" >> /etc/ssh/sshd_config
         echo "O IP $opipnow de interface foi definido!"
     elif [ $listenip = $opipnow ]
     then
           echo
           echo "O IP $opipnow da interface já foi definido anteriormente!"
     else  
           echo
           sed -i "s/ListenAddress.*/ListenAddress $opipnow/" /etc/ssh/sshd_config
           echo " O IP $listenip anteriormente habilitado foi subistituido por $opipnow!"
     fi
    
elif [ $opintssh = "n" ]
then
    echo
    echo "OK. Nenhuma interface será definida!"
 else
    echo
    echo "Opção errada!"
    IPSSH
 fi
}

TCPWP() {

echo
echo -n "Gostaria de configurar o TCP Wrappers para o SSH? [s/n]: "
read chtcpwp
   
if [ $chtcpwp = "s" ]
then

    permallow=$(cat /etc/hosts.allow | grep sshd: | wc -l)

    if [ $permallow -eq 0 ]
    then
        echo
        cp /etc/hosts.allow /etc/hosts.allow.old
        cp /etc/hosts.deny /etc/hosts.deny.old
    
        echo "Configurando o arquivo /etc/hosts.allow do TCP Wrappers para o serviço SSH..."
        echo "Defina os endereços IP's que podem acessar o SSH (Ex: 192.168.1.29 192.168.1.* 192.168.1.0/24 192.168.1.0/255.255.255.0): "
        read ipsrl
        echo " " >> /etc/hosts.allow
        echo "### Endereços IP Liberados ###" >> /etc/hosts.allow
        echo "sshd: $ipsrl" >> /etc/hosts.allow
        echo " " >> /etc/hosts.deny
        echo "### Endereços IP Negados ###" >> /etc/hosts.deny
        echo "sshd: ALL" >> /etc/hosts.deny
    else
        echo
        echo -n "O arquivo /etc/hosts.allow do TCP Wrappers já está configurado para o SSH. Você Gostaria de reconfigurá-lo? [s/n]: "
        read newallow
   
        if [ $newallow = "s" ]
        then
            echo
            echo "Configurando o arquivo /etc/hosts.allow do TCP Wrappers para o serviço SSH..."
            echo "Defina os endereços IP's que podem acessar o SSH (Ex: 192.168.1.29 192.168.1.* 192.168.1.0/24 192.168.1.0/255.255.255.0): "
            read newipsrl
            tnewipsrl=$(echo "$newipsrl" | sed 's/\//\\\//g')
            sed -i "s/sshd:.*/sshd: $tnewipsrl/" /etc/hosts.allow
   
        elif [ $newallow = "n" ]
        then
             echo
             echo "OK. As configurações realizadas em /etc/hosts.allow seram preservadas!"
         else
             echo
             echo "Opção errada!"
             TCPWP
         fi
      fi 

elif [ $chtcpwp = "n" ]
then
    echo
    echo "OK. O TCP Wrappers para o SSH não será configurado!"
	
else
    echo
    echo "Opção errada!"
    TCPWP
fi
}

F2bPort(){
ctsshport=$(cat /etc/ssh/sshd_config | grep -v "#" | grep -E 'Port ?' | cut -d" " -f2 | wc -l)

if [ $ctsshport -eq 0 ]
   then
        echo
        echo "O Fail2Ban nessecita que a opção Port do arquivo /etc/ssh/sshd_config esteja habilitada!"
        PORTSSH
        F2bPort
    else
        sshport=$(cat /etc/ssh/sshd_config | grep -v "#" | grep -E 'Port ?' | cut -d" " -f2)

        if [ $sshport != "22" ]
        then
            echo
            sed -i "/port.*ssh/{ s/port.*ssh/port    = $sshport/;:a;n;ba }" /etc/fail2ban/jail.local
            chsshport=$(cat /etc/fail2ban/jail.local | grep -E "port    = $sshport")
            echo "A seguinte alteração de porta do SSH foi realizada no Fail2Ban: $chsshport"
            sleep 3
        else
            echo
            echo "A porta configurada no Fail2Ban é a padrão do SSH, nenhuma configuração é necessária!"
            sleep 3
        fi
fi
}

CPBANNER() {
echo
echo -n "Instalar os banners issue.net e MOTD em inglês? A opção \"n\" os instalará em português [s/n] ?: "
read banner
if [ $banner = "s" ]
then
cp issue.net.eng /etc/issue.net
cp motd-banner_eng /etc/update-motd.d/00-motd
chmod +x /etc/update-motd.d/00-motd
rm issue.net.pt_BR motd-banner_pt-BR issue.net.eng motd-banner_eng
systemctl restart ssh.service
elif [ $banner = "n" ]
then
cp issue.net.pt_BR /etc/issue.net
cp motd-banner_pt-BR /etc/update-motd.d/00-motd
chmod +x /etc/update-motd.d/00-motd
rm issue.net.pt_BR motd-banner_pt-BR issue.net.eng motd-banner_eng
systemctl restart ssh.service
else
echo
echo "Opção errada!"
echo
sleep 3
CPBANNER
fi
}

FSTReboot() {
   echo
   echo "Você precisa reiniciar a máquina para que o arquivo /etc/fstab seja recarregado!"
   echo
   echo -n "Reiniciar agora? [s/n]: "
   read rbtpc
   
   if [ $rbtpc = "s" ]
   then
       echo
       echo "Bye bye!"
       sleep 5
       echo
       shutdown -r now
   elif [ $rbtpc = "n" ]
   then
       echo
       echo "Ok. A máquina não será reiniciada agora!"
       sleep 3
   else
       echo
       echo "Opção errada!"
       sleep 3
       FSTReboot
   fi
}

#################################################
### Fuções com retorno para o menu principal  ###
#################################################

##############
### RtMenu ###
##############

RtMenu(){
echo
echo "Retornando para o menu principal em 5 segundos..."
sleep 5
clear
menu
}

PKGSRT() {
PKGS
RtMenu
}

UpdatePKGRT() {
UpdatePKG
RtMenu
}

DisKeysRT() {
DisKeys
RtMenu
}

LgtTermRT() {
LgtTerm
RtMenu
}

DisTermRootRT() {
DisTermRoot
RtMenu
}

DisShellRT() {
DisShell
RtMenu
}

GrpPAMRT() {
GrpPAM
RtMenu
}

DisSUIDRT() {
DisSUID
RtMenu
}

ConfigSSHRT() {
ConfigSSH
RtMenu
}

EdiMotdIssueRT() {
EdiMotdIssue
RtMenu
}

Fail2banRT() {
Fail2ban
RtMenu
}

RkhRT() {
Rkh
RtMenu
}

RmPKGRT() {
RmPKG
RtMenu
}

RtIDRT() {
RtID
RtMenu
}

EditFstabRT() {
EditFstab
RtMenu
}

menu
