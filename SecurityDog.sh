#!/bin/bash

######################################################
# Script de Hardening                                #
# Versão: 1.0 (Codinome: Laika)                      #
# Autor: Cairo Ap. Campos                            #
######################################################

clear

if [ "$USER" != "root" ]
then
      echo
      echo "Permission denied! Please become Root to run SecurityDog."
      echo
      exit
fi


## Menu de  escolha de idioma ##
menulang() {
   cat initial.txt
   echo "#############################################################################"
   echo "######                      Languages Options                          ######"
   echo "#############################################################################"
   echo "###  1 - Português                                                        ###"
   echo "###  2 - English                                                          ###"
   echo "#############################################################################"
   echo " "
   echo -n "Choose one of the options above: "
   read option
   case $option in
       1) file="lang_pt-BR.lang" ;;
       2) file="lang_eng.lang" ;;
       *) echo
          echo "Option Invalid! Returning to Menu ..."
          sleep 3
          clear
          menulang ;;
   esac

}

menulang

menuline=(  )

while read line
do
menuline[$n]=$line
n=$((n+1))
done < $file

clear

menu() {
   cat initial.txt
   echo "#############################################################################"
   echo "${menuline[0]}"
   echo "#############################################################################"
   echo "${menuline[1]}"
   echo "${menuline[2]}"
   echo "${menuline[3]}"
   echo "${menuline[4]}"
   echo "${menuline[5]}"
   echo "${menuline[6]}"
   echo "${menuline[7]}"
   echo "${menuline[8]}"
   echo "${menuline[9]}"
   echo "${menuline[10]}"
   echo "${menuline[11]}"
   echo "${menuline[12]}"
   echo "${menuline[13]}"
   echo "${menuline[14]}"
   echo "${menuline[15]}"
   echo "${menuline[16]}"
   echo "${menuline[17]}"
   echo "#############################################################################"
   echo
   echo -n "${menuline[18]}"
   read option
   case $option in
       1) StartAllOptions ;;
       2) InstallPKGRT ;;
       3) UpdatePKGRT ;;
       4) DisKeysRT ;;
       5) LgtTermRT ;;
       6) DisTermRootRT ;;
       7) DisShellRT ;;
       8) GrpPAMRT ;;
       9) DisSUIDRT ;;
       10) ConfigSSHRT ;;
       11) EdiMotdIssueRT ;;
       12) Fail2banRT ;;
       13) RkhRT ;;
       14) RmPKGRT ;;
       15) RtIDRT ;;
       16) EditFstabRT;;
       0) exit ;;
       *) echo " "
          echo "Opção Invalida! Retornando ao Menu..."
          sleep 3
          clear
          menu ;;
   esac

}

# Inicia todas as opções
StartAllOptions() {
clear
cat initial.txt
echo "############################################################################"
echo "###  Atualizando lista de pacotes e instala pacotes para o hardening  ###"
echo "############################################################################"
InstallPKG
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
echo "###    Desabilitando Shell de usuários/serviços que não fazen login      ###"
echo "############################################################################"
DisShell
echo
echo "############################################################################"
echo "###              Habilitando grupo que pode usar o comando su            ###"
echo "############################################################################"
GrpPAM
echo
echo "############################################################################"
echo "###                    Removendo Suid bit de comandos                    ###"
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
echo "###           Rkhunter - Analisa o sistema em busca de Rootkits          ###"
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
echo "###                Protegendo Partições listadas em /etc/fstab           ###"
echo "############################################################################"
EditFstab
RtMenu
}

#############################################################################
###  Fuções sem retorno para o Menu usadas pela a função StartAllOptions  ###
#############################################################################

## Atulizar lista de pacotes disponiveis e instala pacotes necessários para o harderning ##
InstallPKG() {
echo
apt update && apt install -y debsecan fail2ban htop rkhunter
}

## Atualiza pacotes e agenda tarefa de atualização no Cron ##
UpdatePKG() {

findbin=$(which debsecan | wc -l)

if [ $findbin -eq 0 ]
then 
    echo
    echo "Os pacotes para o hardening não foram instalados!"
    sleep 3
    echo
    echo "Instalando pacotes... "
    sleep 3
    InstallPKG
    clear
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

## Desabilitar CTRL+ALT+DEL ##
DisKeys() {
echo
systemctl mask ctrl-alt-del.target
systemctl daemon-reload
echo
echo "Reboot via teclas CTRL+ALT+DEL desativado com sucesso!"
}

## Logout automático do terminal após quantidade de minutos de inatividade ##
LgtTerm() {
echo
echo -n  "Digite o tempo de inatividade tolerado para logout automático (Digitar tempo em minutos): "
read tmplgt
calctmp=$((tmplgt*60))
echo "export TMOUT=$calctmp" >> /etc/profile
source /etc/profile
echo
echo "O tempo de $tmplgt minutos, foi definido com sucesso!"
}

## Desabilita login direto do root nos terminais de texto (tty) do servidor ##
DisTermRoot() {
echo
for i in $(seq 12);
do
ntty=$(echo "tty$i")
ctty=$(echo "#tty$i")
sed -i "/$ntty/{ s/$ntty/$ctty/;:a;n;ba }" /etc/securetty
done
echo "Terminais desabilitados (tty1 à tty12) para o login do Root! "
}

## Remover shell válidas de usuarios que não precisam fazer login ##
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
   echo
   done < gnusr.txt

else
   echo
   echo "Não há usuários com shells mal configuradas!" | tee Reports/UserShells_$dts.txt
fi

rm gnusr.txt vldusr.txt
}

## Habilita no PAM o grupo que pode utilizar o comando su ##
GrpPAM() {
echo
echo -n  "Digite um nome para o grupo que poderá utilizar o su: "
read gname
fgroup=$(cat /etc/group | cut -f 1 -d: | grep $gname)
if [ -z $fgroup ]
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

pamline=$(cat /etc/pam.d/su | grep group=$gname | cut -f 2 -d=)

if [ -z $pamline ]
then
    sed -i "/#.*pam_wheel.so/{ s/#.*pam_wheel.so/auth required pam_wheel.so group=$gname/;:a;n;ba }" /etc/pam.d/su
    echo
    echo "O grupo $gname foi habilitado para usar o su!"
else
    echo
    echo "O grupo $gname já está configurado para usar o su!"
fi

sed -i -r 's/^#(.*SULOG_FILE.*)$/\1/' /etc/login.defs
touch /var/log/sulog
echo
echo "Para visualizar logs da utilização do comando su, utilize o arquivo /var/log/sulog."
sleep 5
}

## Remover Suid bit de comandos ##
DisSUID() {
echo
echo "O Suid bit foi removido dos seguintes comandos: "
echo
for sbcmd in $(find / -perm -4000 2> /dev/null | grep -v /bin/su | grep -v /usr/bin/passwd)
do
chmod -s $sbcmd
echo "$sbcmd"
done
}

## Configuração do SSH ##
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

## Configurar arquivos Motd e Issue.net ##
EdiMotdIssue() {
echo
echo "Desabilitando mensagem de caixa de e-mail no login"
sed  -i "s/session    optional     pam_mail.so/#session    optional     pam_mail.so/" /etc/pam.d/sshd
echo
echo "Habilitando o issue.net em /etc/ssh/sshd_config"
sed -i 's/#Banner.*none/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
echo
echo "Desabilitando antigos arquivos do motd"
chmod -x /etc/update-motd.d/10-uname
mv /etc/update-motd.d/10-uname /etc/update-motd.d/10-uname.old
mv /etc/motd /etc/motd.old
mv /etc/issue /etc/issue.old
mv /etc/issue.net /etc/issue.net.old
CPBANNER
}

## Configuração Fail2ban ##
Fail2ban() {

findbin2=$(which fail2ban-server | wc -l)

if [ $findbin2 -eq 0 ]
then 
    echo
    echo "Os pacotes para o hardening não foram instalados!"
    sleep 3
    echo
    echo "Instalando pacotes... "
    sleep 3
    InstallPKG
    clear
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

Rkh() {
echo
sed -i 's/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf
sed -i 's/MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf
sed -i 's/WEB_CMD="\/bin\/false"/WEB_CMD=""/' /etc/rkhunter.conf
sed -i 's/CRON_DAILY_RUN=""/CRON_DAILY_RUN="true"/' /etc/default/rkhunter
sed -i 's/CRON_DB_UPDATE=""/CRON_DB_UPDATE="true"/' /etc/default/rkhunter

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
}

RmPKG() {
echo
echo "Removendo pacotes desnecessários: "
echo
apt purge -y bluez bluetooth crda iw libiw30:amd64 wireless-regdb wireless-tools wpasupplicant 
apt purge -y netcat-traditional telnet wget git
apt autoremove -y
apt clean
}

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
    echo
    echo "$userid"
    echo
    echo "Configuração em /etc/passwd: "
    echo
    echo "$infoid"
else
    echo
    echo "O usuário com o ID 0 é o: $userid"
    echo
    echo "Configuração em /etc/passwd: "
    echo
    echo "$infoid"
fi
}

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
   fi
done < clFstab.txt

echo
echo "Reinicie a máquina para que o arquivo /etc/fstab seja recarregado!"

}

###########################
### Funções especificas ###
###########################

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

GNSSH() {
sed -i 's/#.*prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/" /etc/ssh/sshd_config
echo
echo "As configurações básicas foram definidas com sucesso!"
}

PORTSSH() {
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
}

GRPSSH() {
echo
echo -n "Você deseja criar um grupo para usuários que poderão fazer login no SSH? [s/n]: "
read opgpssh

if [ $opgpssh = "s" ]
then
    echo
    echo -n  "Digite um nome para o grupo que poderá logar no ssh: "
    read sshgname
    fsshgrp=$(cat /etc/group | cut -f 1 -d: | grep $sshgname)
    
    if [ -z $fsshgrp ]
    then
        groupadd $sshgname
        echo
        echo  "O grupo $sshgname foi inserido com sucesso!"
     else
        echo
        echo "O grupo $sshgname já existe!"
     fi

     ls /home/ | grep -v lost+found > usrssh.txt

      while read lineusrssh
      do
      echo
      addgroup $lineusrssh $sshgname
      done < usrssh.txt

      rm usrssh.txt

      sshdgrp=$(cat /etc/ssh/sshd_config | grep AllowGroups | cut -f 2 -d" ")

      if [ -z $sshdgrp ]
      then
          echo " " >> /etc/ssh/sshd_config
          echo "# Additional Settings" >> /etc/ssh/sshd_config
          echo "AllowGroups $sshgname " >> /etc/ssh/sshd_config
          echo
          echo "O grupo $sshgname foi habilitado para usar o ssh!"
       elif [ $sshdgrp = $sshgname ]
       then
           echo
           echo "O grupo $sshgname já foi definido anteriormente!"
       else  
           echo
           sed -i "s/AllowGroups.*/AllowGroups $sshgname/" /etc/ssh/sshd_config
           echo " O grupo $sshdgrp anteriormente habilitado para usar o ssh, foi subistituido por $sshgname!"
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

     if [ -z $listenip]
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
           echo " O grupo $listenip anteriormente habilitado para usar o ssh, foi subistituido por $opipnow!"
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
cp /etc/hosts.allow /etc/hosts.allow.old
cp /etc/hosts.deny /etc/hosts.deny.old
echo "Defina os endereços IP's que podem acessar o SSH (Ex: 192.168.1.29 192.168.1.* 192.168.1.0/24 192.168.1.0/255.255.255.0): "
read ipsrl
echo " " >> /etc/hosts.allow
echo " " >> /etc/hosts.deny
echo "sshd: $ipsrl" >> /etc/hosts.allow
echo "sshd: ALL" >> /etc/hosts.deny
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

#######################################
### Fuções com retorno para o Menu  ###
#######################################

RtMenu(){
echo
echo "Retornando para o menu principal em 5 segundos..."
sleep 5
clear
menu
}

InstallPKGRT() {
InstallPKG
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
