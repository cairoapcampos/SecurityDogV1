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
   read opcao
   case $opcao in
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

var=(  )

while read line
do
var[$n]=$line
n=$((n+1))
done < $file

clear

menu() {
   cat initial.txt
   echo "#############################################################################"
   echo "${var[0]}"
   echo "#############################################################################"
   echo "${var[1]}"
   echo "${var[2]}"
   echo "${var[3]}"
   echo "${var[4]}"
   echo "${var[5]}"
   echo "${var[6]}"
   echo "${var[7]}"
   echo "${var[8]}"
   echo "${var[9]}"
   echo "${var[10]}"
   echo "${var[11]}"
   echo "${var[12]}"
   echo "${var[13]}"
   echo "${var[14]}"
   echo "${var[15]}"
   echo "${var[16]}"
   echo "#############################################################################"
   echo
   echo -n "${var[18]}"
   read opcao
   case $opcao in
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
echo "###  Atualizando lista de pacotes e instalando pacotes para o hardening  ###"
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
echo "###             Desabilitar login do Root no terminal físico             ###"
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
echo "###                          Configurar Fail2ban                         ###"
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
echo "###                    Verificar duplicidade de ID do Root               ###"
echo "############################################################################"
RtIDRT
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

## Atualiza pacotes que possuem vulnerabilidades corrigidas ##
UpdatePKG() {

codename=$(lsb_release -c | tr -s '[:space:]' ' ' | cut -d ' ' -f2)
ctvulpkg=$(debsecan --suite $codename --only-fixed --format packages | wc -l)

if [ $ctvulpkg -gt 0 ]
then
    echo
    echo "Os seguintes pacotes possuem vulnerabilidades de segurança: "
    echo
    debsecan --suite $codename --only-fixed | tee Update_pkgs.txt
    echo
    echo "Atualizando pacotes vulneraveis: "
    echo
    apt install $(debsecan --suite $codename --only-fixed --format packages)
else
    echo
    echo "Não existe pacotes com correções de vulnerabilidade disponiveis!"
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
echo  "Não existe mais pacotes a serem atualizados!"
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
echo
hmusr=$(ls /home/ | grep -v lost+found)
vldusr=$(echo "root" && echo "$hmusr")

echo "$vldusr" > vldusr.txt

cat /etc/passwd | cut -f 1 -d: > gnusr.txt

while read line
do
sed -i "/$line/d" gnusr.txt
done < vldusr.txt

while read line2
do
usermod -s /bin/false $line2 &> /dev/null
done < gnusr.txt

rm gnusr.txt vldusr.txt

echo "Shells removidas com sucesso!"
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

## Configurar arquivos Motd e Issue.net ##
EdiMotdIssue() {
echo
echo "Desabilitando mensagem de caixa de e-mail no login"
sed  -i "s/session    optional     pam_mail.so/#session    optional     pam_mail.so/" /etc/pam.d/sshd
echo
echo "Habilitando o issue.net no ssh"
sed -i 's/#Banner.*none/Banner \/etc\/issue.net/' /etc/ssh/sshd_config
echo
echo "Desabilitando antigos arquivos do motd"
chmod -x /etc/update-motd.d/10-uname
mv /etc/update-motd.d/10-uname /etc/update-motd.d/10-uname.old
mv /etc/motd /etc/motd.old
mv /etc/issue /etc/issue.old
mv /etc/issue.net /etc/issue.net.old
cd $HOME/SecurityDog
CPBANNER
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

## Configuração Fail2ban ##
Fail2ban() {
echo
echo -n "Você deseja alterar as configurações padrão do Fail2ban? [s/n]: "
read f2b

if [ $f2b = "s" ]
then

cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.conf.old

echo
echo -n "Defina endereços IP's que não serão bloqueados (Ex: 192.168.0.29 192.168.1.0/24): "
read ips
rips=$(echo "$ips" | sed 's/\//\\\//g')
sed -i "s/ignoreip.*127.0.0.1\/8/ignoreip = 127.0.0.1\/8 $rips/" /etc/fail2ban/jail.conf

echo
echo -n "Defina o tempo em segundos em que o IP ficará banido ou bloqueado: "
read secban
sed -i "s/bantime.*600/bantime = $secban/" /etc/fail2ban/jail.conf

echo
echo -n "Digite o numero máximo de tentaivas de login até um ip ser bloqueado: "
read  attlogin
sed -i "s/maxretry.*5/maxretry = $attlogin/" /etc/fail2ban/jail.conf
echo

echo "Reiniciando serviço do Fail2ban.."
systemctl restart fail2ban.service
echo
echo "Ok.Serviço reiniciado!"

elif [ $f2b = "n" ]
then
echo
echo "OK. As configurações padrão serão mantidas!"
echo
echo "Caso seja necessário fazer alterações posteriores, basta editar o arquivo /etc/fail2ban/jail.conf"
else
echo
echo "Opção errada!"
Fail2ban
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
echo
rkhunter --versioncheck
echo
echo "Atualizando assinaturas de rootkits: "
echo
rkhunter --update
echo
echo "Atualizando as propriedades dos arquivos: "
echo
rkhunter --propupd
echo
echo "Verificando o sistema: "
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

###########################
### Funções especificas ###
###########################

GNSSH() {
sed -i 's/#.*prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords no/" /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
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
sed -i "s/#.*22/Port $newport/" /etc/ssh/sshd_config
echo
echo "A porta foi alterada para $newport!"
elif [ $opport = "n" ]
then
sed -i 's/#.*22/Port 22/' /etc/ssh/sshd_config
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
else
    echo
    sed -i "s/AllowGroups.*/AllowGroups $sshgname/" /etc/ssh/sshd_config
    echo "Já havia um grupo habilitado para usar o ssh, o mesmo foi subistituido por $sshgname!"
fi
}

IPSSH() {
echo
echo "Listando interfaces de rede: "
echo
ip a
echo
echo -n "Escolha um endereço IP de uma das interfaces acima para conectar ao SSH: "
read opip
echo "ListenAddress $opip" >> /etc/ssh/sshd_config
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
DisShel
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

menu









