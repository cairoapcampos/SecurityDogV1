# SecurityDog
Script de hardening em GNU/Linux Debian 9 & 10

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img.png)

## Instruções

1. Ao instalar o sistema, particioná-lo com as seguintes partições além da swap:

`/boot, /, /home, /tmp, /var, /var/log`

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img2.png)

Obs: O tamanho a ser definido para cada partição, deve ser avaliado de acordo com os serviços que serão utilizados.

2. Fazer login como root:

`su -`

3. Instalar o pacote `git`:

`apt install git`

4. Clonar o repositório:

`git clone https://github.com/cairoapcampos/SecurityDogV1.git`

5. Alterar permissões de scripts para que sejam executaveis:

`cd SecurityDogV1`

`chmod 700 SecurityDog.sh DebsecanUpdatePkgs.sh`

6. Rodar o script `SecurityDog.sh`:

`./SecurityDog.sh`
