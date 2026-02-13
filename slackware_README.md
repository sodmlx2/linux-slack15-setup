
# linux-slack15-setup

## User Identity

| Arquivo | Função Básica | O que fazer nele |
| :--- | :--- | :--- |
| `/etc/passwd` | Registro Geral | Adicionar linha com Nome, UID, GID e Home. |
| `/etc/shadow` | Cofre de Senhas | Onde o `passwd` salva a senha criptografada. |
| `/etc/group` | Clubes do Sistema | Adicionar o usuário aos grupos (ex: `audio`, `wheel`). |
| `/etc/gshadow` | Grupos Seguros | Versão protegida do arquivo de grupos (opcional). |
| `/etc/skel/` | Modelo de Casa | Copiar arquivos padrão (`.bashrc`, etc) para a Home. |

---

### Comando de Referência
```bash
useradd -m -g users -G wheel,audio,video -s /bin/bash lab && echo "lab:slackware" | chpasswd && chage -d 0 lab
```bash
useradd -m -g users -G wheel,audio,video -s /bin/bash lab && echo "lab:slackware" | chpasswd && chage -d 0 lab
```
---

# Basic Git Configuration.
```bash
git config --global user.email "user@example.com"
git config --global user.name "username"
```
---

# Network Configuration.
```bash
iwlist wlan0 scan | grep ESSID
nmcli device wifi connect "ESSID" password "PASSWORD"
```

# System Updates & Packages.
```bash
vim /etc/slackpkg/mirrors
slackpkg update
slackpkg upgrade kernel-generic kernel-huge kernel-modules kernel-headers kernel-source
```

# Slackware Kernel Compilation.

This project provides a robust Bash script (`slack_linux.sh`) designed to automate the process of compiling, installing, backing up, and packaging a custom Linux Kernel on Slackware systems.

## Features.

- **Automated Compilation**:  
  Optionally runs `make bzImage` and `make modules` using all available CPU cores (`-j$(nproc)`).
- **Safe Installation**:  
  - Installs kernel binaries (`vmlinuz`, `System.map`, `.config`) to `/boot`.
  - **Backups**: Automatically backs up existing files in `/boot` to `*.old` before overwriting (e.g., `vmlinuz` -> `vmlinuz.old`).
  - **Symlinks**: Updates symbolic links (`/boot/vmlinuz`, `/boot/System.map`, etc.) to point to the new version.
- **Module & Header Installation**:  
  Installs modules and headers to a temporary directory for packaging, and modules to `/lib/modules` for the system.
- **Initrd Generation**:  
  Automatically detects the correct `mkinitrd` command for your system using `mkinitrd_command_generator.sh`, generates a new initrd, handles backups, and updates symlinks.
- **Packaging**:  
  Creates a `.tar.gz` archive containing the kernel, modules, headers, and initrd for easy distribution or backup.
- **Bootloader Update**:  
  Detects and prompts to update your bootloader (LILO, ELILO, or GRUB) to ensure the new kernel is recognized.

## Prerequisites.

- **Root Privileges**: The script must be run as root (or with `sudo`) to write to `/boot`, `/lib/modules`, and update bootloaders.
- **Kernel Source**: You must have the Linux Kernel source code downloaded and extracted (e.g., in `/usr/src/linux`).
- **Build Tools**: Ensure you have the necessary development tools installed (gcc, make, ncurses, etc.).
- **Slackware Tools**: Requires standard Slackware tools like `mkinitrd`.

## Usage.

1.  **Navigate to the Kernel Source Directory**:
    The script **must** be run from the root of your Linux kernel source tree.

    ```bash
    cd /usr/src/linux-6.x.x
    ```

2.  **Run the Script**:
    Execute the script from that directory.

    ```bash
    /path/to/tools/slack_linux.sh
    ```

3.  **Interactive Prompts**:
    The script will guide you through the process:
    - **Project Name**: Enter a suffix for your kernel build (e.g., `custom`).
    - **Compile?**: Choose whether to compile the kernel (`y/N`). If `y`, it will run `make bzImage` and `make modules`.
    - **Bootloader**: At the end, it will ask if you want to update your bootloader (LILO/GRUB).

## Output.

- **System Directories**:
    - `/boot/vmlinuz-generic-X.X.X`
    - `/boot/System.map-X.X.X`
    - `/boot/config-X.X.X`
    - `/boot/initrd-X.X.X.gz`
    - `/lib/modules/X.X.X/`
- **Symlinks**:
    - `/boot/vmlinuz` -> *New Kernel*
    - `/boot/initrd.gz` -> *New Initrd*
- **Backup Archive**:
    - A tarball is created at `/tmp/kernel-dist-<VERSION>-<SUFFIX>.tar.gz` containing all installed files.

## Safety Mechanisms.

- **Dependency Check**: Verifies it is running in a valid kernel source tree.
- **Backups**: Never blindly overwrites `/boot/vmlinuz` or `/boot/initrd.gz`. It moves existing files to `.old` first.

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
