# SecurityDog
Script de hardening em GNU/Linux Debian 9 & 10

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img.png)

## Instruções
### Instalação

1. Ao instalar o sistema, particioná-lo com as seguintes partições além da swap:

`/boot, /, /home, /tmp, /var, /var/log`

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img2.png)

Obs: O tamanho a ser definido para cada partição, deve ser avaliado de acordo com os serviços que serão utilizados.

2.Na janela de `Seleção de software` marcar apenas `servidor ssh` e `utilitários de sistema padrão`.

![Initial Screen](https://github.com/cairoapcampos/SecurityDogV1/raw/master/img3.png)

### Pós-instalação

2. Fazer login como root:

`su -`

3. Criar usuários para a administração do servidor:

```
Ex:

adduser bruce.wayne
adduser clark.kent
adduser hal.jordan
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
