# linux-slack15-setup

# Slackware setup for begging in programming and kernel hacking!

## User.
```bash
useradd -m -g users -G wheel,audio,video -s /bin/bash lab && echo "lab:slackware" | chpasswd && chage -d 0 lab
```

## Git basic config.
```bash
git config --global user.email "user@example.com"
git config --global user.name "username"
```

## Communication.
```bash
iwlist wlan0 scan | grep ESSID
nmcli device wifi connect "ESSID" password "PASSWORD"
```

## System Package.
```bash
vim /etc/slackpkg/mirrors
slackpkg update
slackpkg upgrade kernel-generic kernel-huge kernel-modules kernel-headers kernel-source
```

## Generating SSH Keys.
```bash
ssh-keygen -t ed25519 -C "user@test.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh -T git@github.com
```

## Make INITRD.
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

## Adjust support ELILO textmenu.

```bash
cd /usr/share/doc/elilo-3.16/examples/textmenu_chooser/
mv general.msg params.msg textmenu-message.msg /boot/efi/EFI/Slackware/
```
