#!/usr/bin/env bash

export PATH="/sbin:/usr/sbin:/bin:/usr/bin:$PATH"

echo -e "\n--- Linux Kernel ---"

#
# Gathering info about the linux kernel.
#
if [ ! -f "Makefile" ] || [ ! -d "arch" ]; then
    echo -e "\n[ERROR]: Execute this script inside the linux kernel -> ./linux/slack-kernel.sh\n"
    exit 1
fi

K_VER=$(make -s kernelrelease)

echo -e "[INFO]: Architecture of this Compilation: $K_VER"

#
# Creating the First Project!
#
read -r -p "> Project: " SUFIXO
SUFIXO_CLEAN="${SUFIXO// /-}"
DEST_DIR="/$HOME/kernel-dist-${K_VER}-${SUFIXO_CLEAN}"

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

    # echo -e "\n[INFO]: Cleaning previous compilation files (make mrproper)..."
    # make mrproper

    # echo "[INFO] Updating copied configuration..."
    # make olddefconfig

    # echo -e "\n[INFO]: Opening menuconfig. Please save your changes and exit when done."
    # make menuconfig

    # Calculate number of cores for parallel compilation.
    CORES=$(nproc)

    # compiling.
    echo -e "[INFO]: Compiling Kernel (bzImage) with $CORES threads."

    make -j"$CORES" bzImage

    echo "[INFO]: Compiling Modules with $CORES threads."

    make -j"$CORES" modules

    # Update K_VER in case it changed (though usually determined by .config)
    K_VER=$(make -s kernelrelease)

    echo -e "[INFO]: Kernel version verified: $K_VER"
fi

#
# verify ouput of bzImage files.
#
BZ_PATH="arch/x86/boot/bzImage"
if [ ! -f "$BZ_PATH" ]; then
    echo "[ERRO]: bzImage não encontrado em $BZ_PATH"
    exit 1
fi

#
# Install Modules.
#
echo -e "\n[INFO] Instalando módulos na pasta temporária e no sistema..."
make modules_install INSTALL_MOD_PATH="$DEST_DIR/modules"

echo -e "\n[INFO] Instalando módulos base e headers no root..."
make modules_install
make headers_install INSTALL_HDR_PATH="$DEST_DIR/headers"

#
# Configure Slackware Boot Files.
#
echo -e "\n[INFO] Realizando backup e instalando novo Kernel no /boot..."
# vmlinuz, System.map and config direct install logic
for file in vmlinuz System.map config; do
    if [ -f "/boot/$file" ] || [ -h "/boot/$file" ]; then
        mv -vf "/boot/$file" "/boot/$file.old"
    fi
done

#
# Setup Basic Linux Kernel file for Booting and symbolic links.
#
cp -v "$BZ_PATH" "/boot/vmlinuz-generic-$K_VER"
cp -v "System.map" "/boot/System.map-generic-$K_VER"
cp -v ".config" "/boot/config-generic-$K_VER"

ln -sfv "vmlinuz-generic-$K_VER" /boot/vmlinuz
ln -sfv "System.map-generic-$K_VER" /boot/System.map
ln -sfv "config-generic-$K_VER" /boot/config

cp -a /boot/*"-generic-$K_VER" "$DEST_DIR/boot/"

#
# Generate initrd (Slackware).
#
if [ -x /usr/share/mkinitrd/mkinitrd_command_generator.sh ]; then
    echo "[INFO] Gerando initrd com mkinitrd_command_generator..."

    if [ -f "/boot/initrd.gz" ] || [ -h "/boot/initrd.gz" ]; then
        mv -vf /boot/initrd.gz /boot/initrd.gz.old
    fi

    # Generates mkinitrd command based on newly installed kernel modules
    MK_CMD=$(/usr/share/mkinitrd/mkinitrd_command_generator.sh -k "$K_VER" | grep -m1 "^mkinitrd")

    if [ -n "$MK_CMD" ]; then
        echo -e "[INFO] Running: $MK_CMD"
        if eval "$MK_CMD"; then
            echo "[INFO] mkinitrd completed successfully."

            FINAL_INITRD_NAME="initrd-$K_VER.gz"
            FINAL_INITRD_PATH="/boot/$FINAL_INITRD_NAME"

            if [ -f "/boot/initrd.gz" ]; then
                 mv -v "/boot/initrd.gz" "$FINAL_INITRD_PATH"
                 ln -sfv "$FINAL_INITRD_NAME" /boot/initrd.gz
                 cp -v "$FINAL_INITRD_PATH" "$DEST_DIR/boot/"
            fi
        else
            echo "[ERROR] mkinitrd command failed."
        fi
    else
        echo "[WARN] Could not generate mkinitrd command. Falling back to generic mkinitrd."
        mkinitrd -c -k "$K_VER" -f ext4 -r /dev/sda1 -m ext4 -o /boot/initrd.gz

        FINAL_INITRD_NAME="initrd-$K_VER.gz"
        FINAL_INITRD_PATH="/boot/$FINAL_INITRD_NAME"

        if [ -f "/boot/initrd.gz" ]; then
             mv -v "/boot/initrd.gz" "$FINAL_INITRD_PATH"
             ln -sfv "$FINAL_INITRD_NAME" /boot/initrd.gz
             cp -v "$FINAL_INITRD_PATH" "$DEST_DIR/boot/"
        fi
    fi
fi

echo -e "[INFO] Packing Linux Kernel Files."
tar -czf "${DEST_DIR}.tar.gz" -C "$DEST_DIR" .

#
# QEMU Linux Lenovo INTEL.
#
if command -v qemu-system-x86_64 > /dev/null; then
    echo -e "\n[INFO] QEMU detected."
    read -r -p "Run QEMU to test the new kernel? [y/N] " RUN_QEMU
    if [[ "$RUN_QEMU" =~ ^[Yy]$ ]]; then
        # Resolve INITRD if not set (e.g. if mkinitrd block was skipped)
        if [ -z "$FINAL_INITRD_PATH" ]; then
             if [ -f "/boot/initrd-${K_VER}.gz" ]; then
                 FINAL_INITRD_PATH="/boot/initrd-${K_VER}.gz"
             elif [ -f "/boot/initrd.gz" ]; then
                 FINAL_INITRD_PATH="/boot/initrd.gz"
             fi
        fi

        QEMU_CMD="qemu-system-x86_64 -m 2048 -kernel $BZ_PATH"
        if [ -n "$FINAL_INITRD_PATH" ]; then
            QEMU_CMD="$QEMU_CMD -initrd $FINAL_INITRD_PATH"
        fi

        # Check for KVM
        if [ -w /dev/kvm ]; then
            QEMU_CMD="$QEMU_CMD -enable-kvm"
        else
            echo "[WARN] /dev/kvm not accessible, running without KVM acceleration."
        fi

        read -r -p "Enter path to Root Disk Image (s to skip/kernel-only test): " DISK_IMG
        if [ "$DISK_IMG" != "s" ] && [ -n "$DISK_IMG" ] && [ -f "$DISK_IMG" ]; then
             QEMU_CMD="$QEMU_CMD -drive file=$DISK_IMG,format=raw"
             # Try to guess root?
             QEMU_CMD="$QEMU_CMD -append \"root=/dev/sda1 ro\"" 
        else
             echo "[INFO] Running kernel-only test (will likely panic on root mount)."
             QEMU_CMD="$QEMU_CMD -append \"panic=1\""
        fi

        echo "[INFO] Executing: $QEMU_CMD"
        eval "$QEMU_CMD"
    fi
else
    echo "[INFO] qemu-system-x86_64 not found. Skipping QEMU test."
fi
