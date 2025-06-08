#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo -e "\nChecking that minimal requirements are ok"

# Detectar sistema operativo
if [ -f /etc/centos-release ]; then
    inst() { rpm -q "$1" &> /dev/null; }
    if (inst "centos-stream-repos"); then
        OS="CentOS-Stream"
    else
        OS="CentOs"
    fi    
    VERFULL="$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)"
    VER="${VERFULL:0:1}"
elif [ -f /etc/fedora-release ]; then
    inst() { rpm -q "$1" &> /dev/null; }
    OS="Fedora"
    VERFULL="$(sed 's/^.*release //;s/ (Fin.*$//' /etc/fedora-release)"
    VER="${VERFULL:0:2}"
elif [ -f /etc/lsb-release ]; then
    OS="$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')"
    VER="$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')"
elif [ -f /etc/os-release ]; then
    OS="$(grep -w ID /etc/os-release | sed 's/^.*=//')"
    VER="$(grep -w VERSION_ID /etc/os-release | sed 's/^.*=//')"
else
    OS="$(uname -s)"
    VER="$(uname -r)"
fi

ARCH=$(uname -m)
echo "Detected : $OS $VER $ARCH"

if [[ "$OS" = "Ubuntu" && ( "$VER" = "20.04" || "$VER" = "22.04" || "$VER" = "24.04" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI."
    echo "Use Ubuntu LTS Version 20.04, 22.04, or 24.04."
    exit 1
fi

# Instalar dependencias necesarias
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-dev unzip wget >/dev/null

cd /root

# Descargar y descomprimir el archivo ZIP
echo "Descargando XUI..."
wget "https://www.dropbox.com/scl/fi/53iicldwz2uhxyxy359po/XUI_1.5.12.zip?rlkey=t0dw3zhuczpq3xegqrdnqkx0m&dl=1" -O XUI_1.5.12.zip
unzip XUI_1.5.12.zip >/dev/null

# Descargar script Python
echo "Descargando script de instalación..."
wget https://raw.githubusercontent.com/TalaveraSama/install-xui/refs/heads/main/install.python3 -O /root/install.python3

# Validar y ejecutar
if [ ! -f /root/install.python3 ]; then
    echo "No se pudo descargar el script Python de instalación"
    exit 1
fi

python3 /root/install.python3
