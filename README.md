# SecurityDog V1.0 ![projects-microcontroller](https://img.shields.io/badge/script-shell-blue)
Script de hardening em GNU/Linux Debian 9 & 10

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img.png)

## Instruções
### Instalação

1. Utilizar para a instalação uma iSO "netinst" para que se possa fazer uma instalação minima.

2. Ao instalar o sistema criar um usuário genérico para login. Por padrão criamos o usuário `manager`.

3. As seguintes partições deverão ser criadas além da swap:

`/boot, /, /home, /tmp, /var, /var/log`

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img2.png)

Obs: O tamanho a ser definido para cada partição, deve ser avaliado de acordo com os serviços que serão utilizados.

4. Na janela de `Seleção de software` marcar apenas a opção `servidor ssh` caso seja necessária.

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img3.png)

### Pós-instalação

#### Criação de Usuários

1. Fazer login como root:

`su -`

2. Criar usuários para a administração do servidor:

```
Ex:
adduser pedro 
adduser maria
adduser jose
```
Atenção! De acordo com o item `2.3.11 Habilitar grupo que pode usar o comando su` no arquivo `ArtigoV4.pdf` presente na pasta Docs do projeto, quando um grupo é criado para usar o comando `su`, os usuários válidos que possuem uma pasta no diretório `/home` são adicionados automaticamente nele. Esse recurso é interessante para a maioria dos servidores, porém quando o servidor é um file server e/ou um servidor de dominio, o script deve ser alterado para que a pasta dos usuários administradores não seja `/home`, já que este diretório geralmente contém as pastas de todos usuários de uma organização que de forma errônea poderiam ser adicionados ao grupo. Na versão do 2 do script esse problema irá ser corrigido.  

#### Execução do Script

1. Instalar o pacote `git`:

`apt install git`

2. Clonar o repositório:

`git clone https://github.com/cairoapcampos/SecurityDogV1.git`

3. Alterar permissões de scripts para que sejam executaveis:

`cd SecurityDogV1`

`chmod 700 SecurityDog.sh DebsecanUpdatePkgs.sh`

4. Rodar o script `SecurityDog.sh`:

`./SecurityDog.sh`


### Instalação de novos pacotes após o hardening

1. Para os casos seguintes será necesssário que as partições `/var` e `/tmp` sejam remontadas com permissão de execução:

* Instalar e desinstalar pacotes no sistema usando os comando apt-get, apt e aptitude;
* Uma nova execução do script afim de alterar alguma configuração realizada anteriormente.

**Obs: As opções de hardening 1, 2, 3, 12, 13 e 14 necessitam de permissão de execução nestas partições.**

Comandos para remontar as partições com permissão de execução:

```
mount -o remount,rw,exec /var
mount -o remount,rw,exec /tmp
```
2. Após a instalação dos pacotes ou nova execução do script, as pastas precisam novamente serem remontadas com permissão de não execução.

Comandos para remontar as partições com permissão de não execução:

```
mount -o remount,rw,noexec /var
mount -o remount,rw,noexec /tmp
```
