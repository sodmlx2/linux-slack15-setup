#!/usr/bin/env bash

clear

set -e

echo -e "\n--- Linux Kernel Slackware ---\n"

#
# loading basic configs.
#

if [ ! -f "Makefile" ] || [ ! -d "arch" ]; then
    echo -e "\n[ERROR]: Execute this script here -> ./linux/scripts/slack-kernel.sh\n"
    exit 1
fi

K_VER=$(make -s kernelrelease)
echo "[INFO]: Version of this compilation: $K_VER"

ARCH_RAW=$(uname -m)
case $ARCH_RAW in
    x86_64|i386|i686) ARCH_DIR="x86" ;;
    *)                ARCH_DIR="$ARCH_RAW" ;;
esac

echo -e "[INFO]: Architecture of this compilation: $ARCH_RAW \n"

read -r -p "> Project: " SUFIXO
SUFIXO_CLEAN="${SUFIXO// /-}"
DEST_DIR="/tmp/kernel-dist-${K_VER}-${SUFIXO_CLEAN}"

#
# loading config file.
#


#
# Create the folder of project compilation.
#

[ -d "$DEST_DIR" ] && rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"/{boot,modules,headers}

#
# Basic Linux Kernel Compile Process.
#
read -r -p "Do you want to compile the kernel? [y/N] " COMPILE_KERNEL

if [[ "$COMPILE_KERNEL" =~ ^[Yy]$ ]]; then

    # Calculate number of cores for parallel compilation.
    CORES=$(nproc)

    # generating .config file with kernel configurations.
    echo -e "\n[INFO]: Generating Config file."
    make menuconfig

    # Generated image of linux kernel.
    echo -e "[INFO]: Compiling Kernel (bzImage) with $CORES threads."
    make -j"$CORES" bzImage

    # Compile modules of linux kernel.
    echo "[INFO]: Compiling Modules with $CORES threads."
    make -j"$CORES" modules

    # Update K_VER in case it changed (though usually determined by .config)
    K_VER=$(make -s kernelrelease)
    echo -e "[INFO]: Kernel version verified: $K_VER."
fi

#
# Copying and Backup the Linux Kernel Files generated in process of compilation.
#
function install_kernel_file() {
    local SOURCE_FILE="$1"
    local DEST_NAME="$2"
    local SYMLINK_NAME="$3"

    if [ -f "$SOURCE_FILE" ]; then
        local DEST_PATH="/boot/$DEST_NAME"

        # Backup existing versioned file if it exists
        if [ -f "$DEST_PATH" ]; then
            echo -e "\n[INFO] Backing up existing $DEST_PATH to ${DEST_PATH}.old"
            mv -v "$DEST_PATH" "${DEST_PATH}.old" >> logs2.txt
        fi

        echo -e "[INFO] Installing $SOURCE_FILE to /boot/$DEST_NAME and $DEST_DIR/boot/$DEST_NAME"
        cp -v "$SOURCE_FILE" "$DEST_DIR/boot/$DEST_NAME" >> logs2.txt
        cp -v "$SOURCE_FILE" "$DEST_PATH" >> logs2.txt

        # Handle Symlink
        if [ -n "$SYMLINK_NAME" ]; then
            local LINK_PATH="/boot/$SYMLINK_NAME"
            if [ -L "$LINK_PATH" ] || [ -f "$LINK_PATH" ]; then
                # Backup the existing symlink/file to .old
                # If it's a symlink, we just rename the link.
                # If it's a file (e.g. old vmlinuz), we rename it too.
                echo -e "[INFO] Backing up previous $SYMLINK_NAME to ${SYMLINK_NAME}.old"
                mv -v "$LINK_PATH" "${LINK_PATH}.old" >> logs2.txt
            fi
            echo "[INFO] Creating symlink $LINK_PATH -> $DEST_NAME"
            ln -sfv "$DEST_NAME" "$LINK_PATH" >> logs2.txt
        fi
    else
        return 1
    fi
}

# verify ouput of bzImage files.
BZ_PATH="arch/$ARCH_DIR/boot/bzImage"
if ! install_kernel_file "$BZ_PATH" "vmlinuz-generic-$K_VER" "vmlinuz"; then
    echo "[ERRO]: bzImage não encontrado em $BZ_PATH"
    exit 1
fi

# call function install_kernel_file!
install_kernel_file "System.map" "System.map-$K_VER" "System.map" || echo "[WARN] System.map not found."
install_kernel_file ".config" "config-$K_VER" "config" || echo "[WARN] .config not found."

# 6. Instalação de Módulos
echo -e "\n[INFO] Instalando módulos na pasta temporária e no sistema..."
make modules_install INSTALL_MOD_PATH="$DEST_DIR/modules" >> logs.txt
# Sincroniza com o sistema real para o mkinitrd funcionar
mkdir -p "/lib/modules/$K_VER"
cp -a "$DEST_DIR/modules/lib/modules/$K_VER/." "/lib/modules/$K_VER/" >> logs2.txt
depmod -a "$K_VER"

# 7. Instalação de Headers
echo "[INFO] Installing the linux headers."
make headers_install INSTALL_HDR_PATH="$DEST_DIR/headers" >> logs.txt

# 8. Geração do initrd (Lógica Robusta)
if [ -x /usr/share/mkinitrd/mkinitrd_command_generator.sh ]; then
    echo "[INFO] Generate initrd."
    # Pega o comando sugerido
    MK_CMD=$(/usr/share/mkinitrd/mkinitrd_command_generator.sh -k "$K_VER" | grep "mkinitrd" | head -n 1)

    if [ ! -z "$MK_CMD" ]; then

        # Backup initrd.gz if it exists before generation
        if [ -f "/boot/initrd.gz" ]; then
             echo "[INFO] Backing up /boot/initrd.gz to /boot/initrd.gz.old"
             mv -v /boot/initrd.gz /boot/initrd.gz.old >> logs2.txt
        fi

        # Executa o comando (geralmente gera /boot/initrd.gz)
        eval "$MK_CMD"

        # Define o nome final com versão
        FINAL_INITRD_NAME="initrd-$K_VER.gz"
        FINAL_INITRD_PATH="/boot/$FINAL_INITRD_NAME"

        # Verifica se o arquivo foi gerado e move/copia
        # mkinitrd usually outputs to /boot/initrd.gz by default or what is specified in -o
        # Assuming -o /boot/initrd.gz or similar.
        # slack-kernel.sh/mkinitrd_command_generator often outputs just the command.

        if [ -f "/boot/initrd.gz" ]; then
             # Rename the generated generic initrd to versioned
             mv -v /boot/initrd.gz "$FINAL_INITRD_PATH" >> logs2.txt
        fi

        # If the generated file was already specified with output name in MK_CMD (unlikely for default generator)
        # We just check if FINAL_INITRD_PATH exists now.

        if [ -f "$FINAL_INITRD_PATH" ]; then
            cp -v "$FINAL_INITRD_PATH" "$DEST_DIR/boot/" >> logs2.txt

            # Create symlink initrd.gz -> initrd-$K_VER.gz
            # We already agreed that initrd.gz is the generic link name
            echo "[INFO] Creating symlink /boot/initrd.gz -> $FINAL_INITRD_NAME"
            ln -sfv "$FINAL_INITRD_NAME" /boot/initrd.gz >> logs2.txt

            echo "[INFO] initrd integrado ao pacote."
        else
            echo "[AVISO]: initrd não encontrado em $FINAL_INITRD_PATH"
        fi
    fi
fi

echo -e "[INFO] Packing Linux Kernel Files."
tar -czf "${DEST_DIR}.tar.gz" -C "$DEST_DIR" .

#
# Apply Bootloader Update.
#
echo -e "[INFO] Checking Bootloader..."

#
# Check for LILO.
#
if [ -f /etc/lilo.conf ] && [ -x "$(command -v lilo)" ]; then
    echo "[INFO] LILO detected."
    read -r -p "Run 'lilo' to update bootloader? [y/N] " RUN_LILO
    if [[ "$RUN_LILO" =~ ^[Yy]$ ]]; then
        lilo
    fi
fi

#
# Check for ELILO (UEFI).
#
if [ -f /etc/elilo.conf ] && [ -x "$(command -v elilo)" ]; then
    echo "[INFO] ELILO detected."
    read -r -p "Run 'elilo' to update bootloader? [y/N] " RUN_ELILO
    if [[ "$RUN_ELILO" =~ ^[Yy]$ ]]; then
        elilo
    fi
fi

#
# Check for GRUB.
#
# if [ -d /boot/grub ]; then
#     if command -v update-grub > /dev/null; then
#         echo "[INFO] GRUB (update-grub) detected."
#         read -r -p "Run 'update-grub'? [y/N] " RUN_GRUB
#         [[ "$RUN_GRUB" =~ ^[Yy]$ ]] && update-grub
#     elif command -v grub-mkconfig > /dev/null; then
#         echo "[INFO] GRUB (grub-mkconfig) detected."
#         read -r -p "Run 'grub-mkconfig -o /boot/grub/grub.cfg'? [y/N] " RUN_GRUB
#         [[ "$RUN_GRUB" =~ ^[Yy]$ ]] && grub-mkconfig -o /boot/grub/grub.cfg
#     fi
# fi
#

echo -e "\n[INFO] Done."
