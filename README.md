# linux-slack15-setup

Este repositório contém guias e ferramentas para automação, compilação de kernel e configuração de ambiente no Slackware 15, com foco em desenvolvimento C++ e DevSecOps.

## Índice de Configurações

Clique nos links abaixo para ser direcionado aos detalhes técnicos no arquivo [slack_README.md](slack_README.md):

1.  **[Compilação do Kernel Slackware](slackware_README.md#slackware-kernel-compilation)**
    * Uso do script `slack_linux_bkp.sh` e automação de builds.
2.  **[Criação de Usuário](slackware_README.md#user-creation)**
    * Setup rápido de usuário para lab com permissões de hardware.
3.  **[Configuração Avançada do Git](slackware_README.md#basic-git-configuration)**
    * Ajustes para Kernel Dev e performance em projetos C++.
4.  **[Configuração de Rede](slackware_README.md#network-configuration)**
    * Comandos CLI para Wi-Fi e NetworkManager.
5.  **[Atualizações de Sistema e Pacotes](slackware_README.md#system-updates--packages)**
    * Gestão de espelhos e upgrade de pacotes base do kernel.
6.  **[Geração de Chaves SSH](slackware_README.md#generating-ssh-keys)**
    * Criação de chaves Ed25519 e autenticação no GitHub.
7.  **[Geração de INITRD](slackware_README.md#generating-initrd)**
    * Comandos específicos para módulos de armazenamento e HID.
8.  **[Ajustes de Menu ELILO](slackware_README.md#adjusting-elilo-text-menu-support)**
    * Ativação do suporte a menus de texto no boot EFI.
9.  **[Forensic e DevSecOps](slackware_README.md#tools-for-forensic-and-devsecops)**
    * Ferramentas para análise de segurança e binários.

---

## Tools `slack_linux_bkp.sh`

* **Compilação Paralela**: Detecta núcleos automaticamente via `nproc`.
* **Segurança**: Faz backup de `vmlinuz` e `initrd.gz` para `.old` antes de sobrescrever.
* **Empacotamento**: Gera um `.tar.gz` contendo tudo (Kernel, Módulos, Headers e Config).

---
## 🚀 Como Iniciar

Para clonar e configurar seu ambiente:
```bash
git clone [https://github.com/seu-usuario/linux-slack15-setup.git](https://github.com/seu-usuario/linux-slack15-setup.git)
cd linux-slack15-setup
chmod +x slack_linux_bkp.sh