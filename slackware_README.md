## SLACK_README

## preaking guide! since 2001

# adicionando usuario e setando as permissoes.
'''
adduser && vim /etc/sudoers
'''

# conetando a uma rede wireless via nmcli.
'''
nmcli device wifi connect "ESSID" password "PASSWORD"
'''
# atualizando os pacotes relacionados ao kernel.
'''
vim /etc/slackpkg/mirrors && slackpkg update
'''
# gerando uma chave SSL para o github.
'''
ssh-keygen -t ed25519 -C "e-mail@test.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
'''
# slackpkg upgrade kernel-generic kernel-huge kernel-modules kernel-headers kernel-source

# gerando um initrd via mkinitrd.
'''
/usr/share/mkinitrd/mkinitrd_command_generator.sh -k 5.15.193
mkinitrd -c -k 5.15.193 -f ext4 -r /dev/nvme0n1p3 -m usb-storage:xhci-hcd:xhci-pci:ohci-pci:ehci-pci:uhci-hcd:ehci-hcd:hid:usbhid:i2c-hid:hid_generic:hid-asus:hid-cherry:hid-logitech:hid-logitech-dj:hid-logitech-hidpp:hid-lenovo:hid-microsoft:hid_multitouch:jbd2:mbcache:crc32c_intel:crc32c_generic:ext4 -u -o /boot/initrd.gz
cp /boot/vmlinuz-generic-5.15.193 /boot/efi/EFI/Slackware/vmlinuz
cp /boot/initrd.gz /boot/efi/EFI/Slackware/initrd.gz
'''
# ajustando o menu do elilo.
'''
cd /usr/share/doc/elilo-3.16/examples/textmenu_chooser/ && mv general.msg params.msg textmenu-message.msg /boot/efi/EFI/Slackware/
'''
