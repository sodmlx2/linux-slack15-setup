# linux-slack15-setup

Este repositório contém guias e ferramentas para automação e compilação de kernel em ambiente (Desenvolvimento C/C++) Slackware 15.

## Índice de Estudos.

1.  **[welcome to the zion archive](slackware_README.md#user-identity)**
    * Setup rápido de usuário para lab com permissões de hardware.
2.  **[O rastreador de conteúdo estúpido](slackware_README.md#basic-git-configuration)**
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
