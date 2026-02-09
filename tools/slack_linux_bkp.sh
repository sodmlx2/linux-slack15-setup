#!/usr/bin/env bash

clear

# 1. Verificação de root
if [ "$EUID" -ne 0 ]; then
  echo "Erro: Este script precisa de privilégios de ROOT."
  exit 1
fi

KVER="5.15.193"
BK_DIR="/root/kernel-safe-$KVER"

echo "--- Iniciando Backup da Arquitetura Slackware ($KVER) ---"

# Criando estrutura limpa
mkdir -p $BK_DIR/boot
mkdir -p $BK_DIR/modules
mkdir -p $BK_DIR/source
mkdir -p $BK_DIR/include

# 2. Backup dos Binários de Boot (Baseado no seu 'ls /boot')
echo "[*] Copiando binários do /boot (Generic, Huge, Config, Maps)..."
cp -a /boot/*$KVER* $BK_DIR/boot/
[ -f /boot/initrd.gz ] && cp -a /boot/initrd.gz $BK_DIR/boot/

# 3. Backup dos Módulos (kernel-modules-$KVER)
echo "[*] Copiando módulos de /lib/modules/$KVER..."
if [ -d /lib/modules/$KVER ]; then
    cp -a /lib/modules/$KVER $BK_DIR/modules/
else
    echo "Aviso: Pasta de módulos não encontrada!"
fi

# 4. Backup do Source e Headers (kernel-source e kernel-headers)
echo "[*] Copiando Source e Headers de sistema..."
# Backup do source (kernel-source-5.15.193-noarch-1)
[ -d /usr/src/linux-$KVER ] && cp -a /usr/src/linux-$KVER $BK_DIR/source/

# Backup dos headers (kernel-headers-5.15.193-x86-1)
# O Slackware os mantém em /usr/include/linux e /usr/include/asm
cp -ar /usr/include/linux $BK_DIR/include/
cp -ar /usr/include/asm $BK_DIR/include/

# 5. Criação dos links simbólicos para o LILO de emergência
echo "[*] Criando links de segurança em /boot..."
# Link para o vmlinuz (priorizando generic conforme sua instalação)
if [ -f /boot/vmlinuz-generic-$KVER ]; then
    ln -sf /boot/vmlinuz-generic-$KVER /boot/vmlinuz-seguro
elif [ -f /boot/vmlinuz-huge-$KVER ]; then
    ln -sf /boot/vmlinuz-huge-$KVER /boot/vmlinuz-seguro
fi

# Link para o initrd
[ -f /boot/initrd.gz ] && ln -sf /boot/initrd.gz /boot/initrd-seguro.gz

echo "--- Backup concluído com sucesso em $BK_DIR ---"

# ajustando o menu do elilo.
cd /usr/share/doc/elilo-3.16/examples/textmenu_chooser/
mv general.msg params.msg textmenu-message.msg /boot/efi/EFI/Slackware/
