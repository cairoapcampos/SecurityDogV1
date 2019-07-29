# SecurityDog
Script de hardening em GNU/Linux Debian 9 & 10

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img.png)

## 1.Instruções

1. Ao instalar o sistema, particioná-lo com as seguintes partições além da swap:

`/boot, /, /home, /tmp, /var, /var/log`

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img2.png)

2. Fazer login como root:

`su -`

3. Clonar o repositório:

`git clone https://github.com/cairoapcampos/SecurityDogV1.git`

4. Alterar permissões de scripts para que sejam executaveis:

`cd SecurityDogV1`

`chmod 700 SecurityDog.sh DebsecanUpdatePkgs.sh`

5. Rodar o script `SecurityDog.sh`:

`./SecurityDog.sh`
