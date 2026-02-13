# linux-slack15-setup

Este repositório contém um guia basico de estudo linux e uma ferramenta para automação e compilação do kernel em ambiente de Desenvolvimento C/C++.

## Índice.

1.  **[Bem-vindo ao Arquivo de Sião](slackware_README.md#user-identity)**
    * Setup rápido de usuário para lab com permissões de hardware.
2.  **[O rastreador de conteúdo estúpido](slackware_README.md#git-configuration)**
    * Ajustes para Kernel Dev e performance em projetos C++.
3.  **[Geração de Chaves SSH](slackware_README.md#generating-ssh-keys)**
    * Criação de chaves Ed25519 e autenticação no GitHub.
4.  **[Configuração de Rede](slackware_README.md#network-configuration)**
    * Comandos CLI para Wi-Fi e NetworkManager.
5.  **[Atualizações de Sistema e Pacotes](slackware_README.md#system-updates--packages)**
    * Gestão de espelhos e upgrade de pacotes base do kernel.
6.  **[Compilação do Kernel Slackware](slackware_README.md#slackware-kernel-compilation)**
    * Uso do script `slack_linux.sh` e automação de builds.
7.  **[Geração de INITRD](slackware_README.md#generating-initrd)**
    * Comandos específicos para módulos de armazenamento e HID.
8.  **[Ajustes de Bootloader](slackware_README.md#adjusting-elilo-text-menu-support)**
    * Ativação do suporte a menus de texto no boot EFI.
9.  **[Forensic e DevSecOps](slackware_README.md#tools-for-forensic-and-devsecops)**
    * Ferramentas para análise de segurança e binários.

# Slackware Kernel Compilation

Este projeto fornece um script Bash robusto (`slack_linux.sh`) desenvolvido para automatizar o processo de compilação, instalação, backup e empacotamento de um kernel Linux customizado em sistemas Slackware.

---

## Funcionalidades

- **Compilação Automatizada**:
  Opcionalmente executa `make bzImage` e `make modules` usando todos os núcleos de CPU disponíveis (`-j$(nproc)`).
- **Instalação Segura**:
  - Instala binários do kernel (`vmlinuz`, `System.map`, `.config`) em `/boot`.
  - **Backups**: Backup automático de arquivos existentes em `/boot` para `*.old` antes de sobrescrever (ex: `vmlinuz` -> `vmlinuz.old`).
  - **Symlinks**: Atualiza links simbólicos (`/boot/vmlinuz`, `/boot/System.map`, etc.) para apontar para a nova versão.
- **Instalação de Módulos e Headers**:
  Instala módulos e headers em um diretório temporário para empacotamento e módulos em `/lib/modules` para o sistema.
- **Geração de Initrd**:
  Detecta automaticamente o comando `mkinitrd` correto usando o `mkinitrd_command_generator.sh`, gera um novo initrd, gerencia backups e atualiza symlinks.
- **Empacotamento**:
  Cria um arquivo `.tar.gz` contendo o kernel, módulos, headers e initrd para fácil distribuição ou backup.
- **Atualização do Bootloader**:
  Detecta e solicita a atualização do seu bootloader (LILO, ELILO ou GRUB) para garantir que o novo kernel seja reconhecido.

---

## Pré-requisitos

* **Privilégios de Root**: O script deve ser executado como root (ou com `sudo`) para gravar em `/boot`, `/lib/modules` e atualizar bootloaders.
* **Código-Fonte do Kernel**: Você deve ter o código-fonte do kernel Linux baixado e extraído (ex: em `/usr/src/linux`).
* **Ferramentas de Build**: Certifique-se de ter as ferramentas de desenvolvimento necessárias (gcc, make, ncurses, etc.).
* **Ferramentas Slackware**: Requer ferramentas padrão do Slackware, como o `mkinitrd`.

---

## Uso

1.  **Navegue até o diretório do código-fonte do kernel**:
    O script **deve** ser executado a partir da raiz da árvore de fontes do kernel.

    ```bash
    cd /usr/src/linux-6.x.x
    ```

2.  **Execute o script**:
    ```bash
    /caminho/para/o/script/slack_linux.sh
    ```

3.  **Prompts Interativos**:
    O script irá guiá-lo pelo processo:
    - **Nome do Projeto**: Insira um sufixo para o build do kernel (ex: `custom`).
    - **Compilar?**: Escolha se deseja compilar o kernel (`y/N`).
    - **Bootloader**: Ao final, ele perguntará se deseja atualizar seu bootloader.

---

## Saída (Output)

* **Diretórios do Sistema**:
    * `/boot/vmlinuz-generic-X.X.X`
    * `/boot/System.map-X.X.X`
    * `/boot/config-X.X.X`
    * `/boot/initrd-X.X.X.gz`
    * `/lib/modules/X.X.X/`
* **Symlinks**:
    * `/boot/vmlinuz` -> *Novo Kernel*
    * `/boot/initrd.gz` -> *Novo Initrd*
* **Arquivo de Backup**:
    * Um tarball é criado em `/tmp/kernel-dist-<VERSÃO>-<SUFIXO>.tar.gz` contendo todos os arquivos instalados.

---

## Mecanismos de Segurança

> [!IMPORTANT]
> - **Verificação de Dependência**: Verifica se está rodando em uma árvore de fontes de kernel válida.
> - **Backups**: Nunca sobrescreve cegamente `/boot/vmlinuz` ou `/boot/initrd.gz`. Ele move arquivos existentes para `.old` primeiro.
>
> - 
## Executando o `slack_linux.sh`.

Configurando o ambiente!

```bash
# Obtendo a ferramenta via git.
cd $HOME && git clone https://github.com/sodmlx2/linux-slack15-setup.git
```
```bash
# Obtendo o Linux Kernel via git.
cd $HOME && git clone git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
```
```bash
# Copiando o script `slack_linux.sh` para o diretorio raiz do linux kernel.
cp $HOME/linux-slack15-setup/tools/slack_linux.sh $HOME/linux
```
```bash
# Executando o script `slack_linux.sh`.
$HOME/linux/slack_linux.sh
```
