## Slackware setup for programming and hacking!

### 1. Adicionando usuário e setando permissões
```bash
adduser && vim /etc/sudoers
```

### 2. Conectando a uma rede wireless via nmcli

```bash
nmcli device wifi connect "ESSID" password "PASSWORD"

```

### 3. Atualizando os pacotes relacionados ao kernel

```bash
# Escolha um espelho (mirror) oficial antes de atualizar
vim /etc/slackpkg/mirrors && slackpkg update

# Atualizando os componentes do Kernel
slackpkg upgrade kernel-generic kernel-huge kernel-modules kernel-headers kernel-source
```

### 4. Gerando uma chave SSH para o GitHub

```bash
ssh-keygen -t ed25519 -C "e-mail@test.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
```

### 5. Gerando o initrd e atualizando o EFI

```bash
# Executar o mkinitrd com módulos divididos por barra para facilitar a leitura
mkinitrd -c -k 5.15.193 -f ext4 -r /dev/nvme0n1p3 \
-m usb-storage:xhci-hcd:xhci-pci:ohci-pci:ehci-pci:uhci-hcd:ehci-hcd:hid:\
usbhid:i2c-hid:hid_generic:hid-asus:hid-cherry:hid-logitech:hid-logitech-dj:\
hid-logitech-hidpp:hid-lenovo:hid-microsoft:hid_multitouch:jbd2:mbcache:\
crc32c_intel:crc32c_generic:ext4 \
-u -o /boot/initrd.gz

# Copiando para a partição EFI
cp /boot/vmlinuz-generic-5.15.193 /boot/efi/EFI/Slackware/vmlinuz
cp /boot/initrd.gz /boot/efi/EFI/Slackware/initrd.gz
```

### 6. Ajustando o menu do ELILO

```bash
cd /usr/share/doc/elilo-3.16/examples/textmenu_chooser/
mv general.msg params.msg textmenu-message.msg /boot/efi/EFI/Slackware/
