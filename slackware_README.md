
# linux-slack15-setup

Este repositório contém guias e ferramentas para automação e compilação de kernel em ambiente de Desenvolvimento C/C++.

## User Identity

### Editar o arquivo `/etc/passwd`

Abra o arquivo com um editor de texto e adicione uma linha para o novo usuário.

A estrutura da linha é: `nome:senha:UID:GID:comentário:home:shell`

<details>
  
<summary>🔥</summary>

> **Exemplo:** `fulano:x:1001:100::/home/fulano:/bin/bash`
>
> **Nota:** O `x` indica que a senha está criptografada no arquivo `shadow`. O `100` é o GID padrão do grupo `users` no Slackware.

</details>

### Editar o arquivo `/etc/group`
Se quiser que o usuário tenha seu próprio grupo, crie uma linha lá.

Se for usar o grupo `users`, apenas verifique se o GID coincide.

<details>
  
<summary>🔥 </summary>

> **Exemplo:** `fulano:x:1001:`
> 
> **Dica:** Adicione o nome do usuário ao final de grupos existentes (como `wheel` ou `audio`) para dar permissões extras.

</details>

### Editar o arquivo `/etc/shadow`
Este arquivo armazena a senha. Como você não terá a hash da senha de cabeça, adicione a linha com a senha bloqueada inicialmente.

<details>
  
<summary>🔥 </summary>

> **Adicione:** `fulano:!:19000:0:99999:7:::`
>
> **Nota:** O sinal de `!` impede o login até que você defina uma senha real usando o comando `passwd`.

</details>

### Resumo.

| Arquivo | Função Básica | O que fazer nele |
| :--- | :--- | :--- |
| `/etc/passwd` | Registro | Adicionar linha com Nome, UID, GID e Home. |
| `/etc/shadow` | Senhas | Onde o `passwd` salva a senha criptografada. |
| `/etc/group` | Grupos | Adicionar o usuário aos grupos (ex: `audio`, `wheel`). |
| `/etc/gshadow` | Grupos Seguros | Versão protegida do arquivo de grupos (opcional). |
| `/etc/skel/` | Esqueleto | Copiar arquivos padrão (`.bashrc`, etc) para a Home. |

### Comando de Referência.
```bash
sudo useradd -m -g users -G wheel,audio,video -s /bin/bash lab && echo "lab:slackware" | sudo chpasswd && sudo chage -d 0 lab
```
---

## Git Configuration.
```bash
git config --global user.email "user@example.com"
git config --global user.name "username"
```
```bash
# Assinar commits automaticamente.
git config --global user.signingkey SEUIDGPG
git config --global commit.gpgsign true
```
```bash
# Configurando um servidor SMTP.
git config --global sendemail.smtpserver smtp.gmail.com
git config --global sendemail.smtpserverport 587
git config --global sendemail.smtpencryption tls
git config --global sendemail.smtpuser seu.email@gmail.com
```
```bash
# Destacar erros de espaço em branco.
git config --global core.whitespace fix,space-before-tab,trailing-space

# Garante que o Git não converta CRLF (Windows) para LF (Linux) de forma destrutiva
git config --global core.autocrlf input
```
---

## Network Configuration.

O NetworkManager é um daemon focado em simplificar a configuração de rede.

Sua função principal é tornar a conexão à internet e o gerenciamento de interfaces algo automático e prático.

```bash
iwlist wlan0 scan | grep ESSID
nmcli device wifi connect "ESSID" password "PASSWORD"
```
---

### Resumo.

| Arquivo | Função Básica | O que fazer nele |
| :--- | :--- | :--- |
| `/etc/NetworkManager/NetworkManager.conf` | Configuração Global | Editar o comportamento do daemon e plugins de DNS. |
| `/etc/NetworkManager/system-connections/` | Perfis de Rede | Armazenar arquivos .nmconnection com SSIDs e senhas. |
| `/etc/NetworkManager/dispatcher.d/` | Automação | Colocar scripts que rodam quando a conexão sobe ou desce. |
| `/etc/NetworkManager/conf.d/` | Configurações Extras | Adicionar fragmentos de configuração para personalização. |
| `/var/lib/NetworkManager/` | Estado de Rede | Consultar leases de DHCP e o estado atual das conexões. |
| `/etc/hostname` | Nome da Máquina | Definir o nome do host que será visto na rede. |

---

## System Updates & Packages.
```bash
vim /etc/slackpkg/mirrors
slackpkg update
slackpkg upgrade kernel-generic kernel-huge kernel-modules kernel-headers kernel-source
```

# Generating SSH Keys.
```bash
ssh-keygen -t ed25519 -C "user@test.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
```

# Generating INITRD.
```bash
mkinitrd -c -k 5.15.193 -f ext4 -r /dev/nvme0n1p3 \
-m usb-storage:xhci-hcd:xhci-pci:ohci-pci:ehci-pci:uhci-hcd:ehci-hcd:hid:\
usbhid:i2c-hid:hid_generic:hid-asus:hid-cherry:hid-logitech:hid-logitech-dj:\
hid-logitech-hidpp:hid-lenovo:hid-microsoft:hid_multitouch:jbd2:mbcache:\
crc32c_intel:crc32c_generic:ext4 \
-u -o /boot/initrd.gz

## Copying file to EFI Slackware.
cp /boot/vmlinuz-generic-5.15.193 /boot/efi/EFI/Slackware/vmlinuz
cp /boot/initrd.gz /boot/efi/EFI/Slackware/initrd.gz
```

# Adjusting ELILO Text Menu Support.

```bash
cd /usr/share/doc/elilo-3.16/examples/textmenu_chooser/
mv general.msg params.msg textmenu-message.msg /boot/efi/EFI/Slackware/
```
# Tools for forensic and DevSecOps.
