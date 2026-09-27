# Manual de Configuração do Kernel Linux (Slackware)

Este guia descreve os caminhos exatos no `menuconfig` para habilitar o suporte a cartões SD, adaptadores USB-Serial (RS232) e o framework de firewall iptables.

---

## 🚩 Iniciando a Configuração

Dentro do diretório do seu kernel (~/repo/src/linux), execute:
```bash
make menuconfig
```

> [!TIP]
> Você pode usar a tecla `/` dentro do menu para pesquisar por qualquer termo (ex: `MMC`, `USB_SERIAL` ou `NETFILTER`).

---

## 1. 📂 Suporte a Cartões SD e MMC
Para que o kernel reconheça leitores de cartão e cartões SD/microSD.

**Caminho:**
`Device Drivers`  --->
  `MMC/SD/SDIO card support`  --->
    - `<*>` `MMC/SD/SDIO card support`
    - `<*>` `MMC block device driver`
    - `<*>` `Secure Digital Host Controller Interface support` (SDHCI)
    - `<*>` `SDHCI support on PCI bus` (Para a maioria dos laptops)
    - `<*>` `SDHCI support on ACPI`

---

## 2. 🔌 Adaptadores USB para Serial (RS232 / ttyUSB0)
Essencial para usar adaptadores como FTDI ou Prolific (RS232 Serial via USB).

**Caminho:**
`Device Drivers`  --->
  `USB support`  --->
    - `<*>` `Support for Host-side USB`
    - `<*>` `USB Serial Converter support`  --->
      - `<*>` `USB Serial Converter support`
      - `<M>` `USB Generic Serial Driver`
      - `<M>` `USB FTDI USB Serial Driver` (Muito comum)
      - `<M>` `USB Prolific 2303 Single Port Serial Driver` (Muito comum)
      - `<M>` `USB CH341 Single Port Serial Driver` (Comum em Arduinos e placas chinesas)

---

## 3. 🛡️ Firewall e Networking (Netfilter / iptables)
Para habilitar o suporte completo ao firewall e roteamento.

**Caminho:**
`Networking support`  --->
  `Networking options`  --->
    - `[*] Network packet filtering framework (Netfilter)`  --->
      - `Core Netfilter Configuration`  --->
        - (Ative tudo como `<M>` ou `<*>`, especialmente `Netfilter connection tracking support`)
      - `IP: Netfilter Configuration`  --->
        - `<M>` `IP tables support (required for filtering/masq/NAT)`
        - `<M>` `IPv4 connection tracking support (required for NAT)`
        - `<M>` `Packet filtering`
        - `<M>` `REJECT target support`
        - `<M>` `iptables NAT support`
        - `<M>` `MASQUERADE target support`

---

## 🚀 Finalizando e Compilando

1. Após selecionar as opções, escolha **Save** e saia do menu.
2. Utilize o seu script para compilar o kernel com as novas funções:
   ```bash
   ./slack_linux.sh
   ```
3. Se você marcou algo como `<M>` (Módulo), o script irá rodar o `make modules` e `make modules_install` automaticamente.

> [!IMPORTANT]
> Lembre-se de rodar o comando `sudo chown -R lab:users .` se encontrar erros de permissão novamente na pasta do kernel.
