# SecurityDog V1.0 ![projects-microcontroller](https://img.shields.io/badge/script-shell-blue)
Script de hardening em GNU/Linux Debian 9 & 10

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img.png)

## Instruções
### Instalação

1. Ao instalar o sistema, particioná-lo com as seguintes partições além da swap:

`/boot, /, /home, /tmp, /var, /var/log`

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img2.png)

Obs: O tamanho a ser definido para cada partição, deve ser avaliado de acordo com os serviços que serão utilizados.

2. Na janela de `Seleção de software` marcar apenas as opções `servidor ssh` e `utilitários de sistema padrão`.

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img3.png)

### Pós-instalação

1. Fazer login como root:

`su -`

2. Criar usuários para a administração do servidor:

```
Ex:
adduser pedro 
adduser maria
adduser jose
```

3. Instalar o pacote `git`:

`apt install git`

4. Clonar o repositório:

`git clone https://github.com/cairoapcampos/SecurityDogV1.git`

5. Alterar permissões de scripts para que sejam executaveis:

`cd SecurityDogV1`

`chmod 700 SecurityDog.sh DebsecanUpdatePkgs.sh`

6. Rodar o script `SecurityDog.sh`:

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
