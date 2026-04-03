#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

ISO_SERVER="$HOME/isooperatingsystem/server2022.iso"
ISO_CLIENT1="$HOME/isooperatingsystem/win10-client1.iso"
ISO_CLIENT2="$HOME/isooperatingsystem/win10-client2.iso"

# Vérifier que l'interface host-only existe
if ! VBoxManage list hostonlyifs | grep -q "vboxnet0"; then
    echo "🔧 Création de l'interface host-only vboxnet0..."
    VBoxManage hostonlyif create
    VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
fi

# Créer les VMs
"$SCRIPT_DIR/1-createvm.sh" "AD-Server"     "Windows2022_64" 4096 60 "$ISO_SERVER"
"$SCRIPT_DIR/1-createvm.sh" "Win10-Client1" "Windows10_64"   4096 50 "$ISO_CLIENT1"
"$SCRIPT_DIR/1-createvm.sh" "Win10-Client2" "Windows10_64"   4096 50 "$ISO_CLIENT2"

echo ""
echo "🎉 Lab prêt. Ordre d'installation recommandé :"
echo "   1. AD-Server     → installer Windows Server 2022, configurer l'AD"
echo "   2. Win10-Client1 → installer Windows 10, joindre le domaine"
echo "   3. Win10-Client2 → idem"
