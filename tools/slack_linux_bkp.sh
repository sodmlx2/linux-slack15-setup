#!/usr/bin/env bash

clear

set -e

echo -e "\n--- Linux Kernel Slackware ---\n"

# ------------- CONFIG -------------

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

# ------------- ENG CONFIG -------------

# 1. Cria a Pasta do projeto de compilacao em /tmp usando o nome do projeto e versao.
[ -d "$DEST_DIR" ] && rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"/{boot,modules,headers}

# 2. Coleta de Binários
BZ_PATH="arch/$ARCH_DIR/boot/bzImage"
if [ -f "$BZ_PATH" ]; then
    echo "[INFO]: Copy bzImage generate with make bziImage modules command!"
    cp -v "$BZ_PATH" "$DEST_DIR/boot/vmlinuz-generic-$K_VER"
    cp -v "$BZ_PATH" "/boot/vmlinuz-generic-$K_VER"
else
    echo "[ERRO]: bzImage não encontrado."
    exit 1
fi

[ -f "System.map" ] && cp -v System.map "$DEST_DIR/boot/System.map-$K_VER" && cp -v System.map "/boot/System.map-$K_VER"
[ -f ".config" ]   && cp -v .config "$DEST_DIR/boot/config-$K_VER" && cp -v .config "/boot/config-$K_VER"

# 6. Instalação de Módulos
echo "[*] Instalando módulos na pasta temporária e no sistema..."
make modules_install INSTALL_MOD_PATH="$DEST_DIR/modules" >> logs.txt
# Sincroniza com o sistema real para o mkinitrd funcionar
mkdir -p "/lib/modules/$K_VER"
cp -a "$DEST_DIR/modules/lib/modules/$K_VER/." "/lib/modules/$K_VER/"
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
        # Executa o comando (geralmente gera /boot/initrd.gz)
        eval "$MK_CMD"

        # Define o nome final com versão
        FINAL_INITRD="/boot/initrd-$K_VER.gz"

        # Verifica se o arquivo foi gerado e move/copia
        if [ -f "/boot/initrd.gz" ]; then
            mv -v /boot/initrd.gz "$FINAL_INITRD"
        fi

        if [ -f "$FINAL_INITRD" ]; then
            cp -v "$FINAL_INITRD" "$DEST_DIR/boot/"
            echo "[INFO]: initrd integrado ao pacote."
        else
            echo "[AVISO]: initrd não encontrado em $FINAL_INITRD"
        fi
    fi
fi

echo -e "\n[INFO] Packing Linux Kernel Files."
tar -czf "${DEST_DIR}.tar.gz" -C "$DEST_DIR" .
