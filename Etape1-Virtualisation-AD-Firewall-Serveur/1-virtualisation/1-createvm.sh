#!/bin/bash
# Usage: ./create-vm.sh <nom_vm> <ostype> <ram_mb> <disk_go> <chemin_iso>
# Exemple AD  : ./create-vm.sh "AD-Server" "Windows2022_64" 4096 60 ~/isooperatingsystem/server2022.iso
# Exemple CLI : ./create-vm.sh "Win10-Client" "Windows10_64" 4096 50 ~/isooperatingsystem/windows10.iso

VM_NAME="$1"
OS_TYPE="$2"
RAM="$3"
DISK_SIZE=$(( $4 * 1000 ))   # conversion Go → Mo pour VBoxManage
ISO_PATH="$5"
VDI_PATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"


if [ $# -lt 5 ]; then
    echo "Usage: $0 <nom_vm> <ostype> <ram_mb> <disk_go> <chemin_iso>"
    exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
    echo "❌ ISO introuvable : $ISO_PATH"
    exit 1
fi

# ✅ Vérification si la VM existe déjà
if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    echo "⚠️  La VM '$VM_NAME' existe déjà, on passe."
    exit 0
fi

echo "🔧 Création de la VM : $VM_NAME"




# Vérification des arguments
if [ $# -lt 5 ]; then
    echo "Usage: $0 <nom_vm> <ostype> <ram_mb> <disk_go> <chemin_iso>"
    exit 1
fi

if [ ! -f "$ISO_PATH" ]; then
    echo "❌ ISO introuvable : $ISO_PATH"
    exit 1
fi

echo "🔧 Création de la VM : $VM_NAME"

# 1. Créer et enregistrer la VM
VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "$OS_TYPE" \
    --register

# 2. Configurer les paramètres système
VBoxManage modifyvm "$VM_NAME" \
    --memory "$RAM" \
    --cpus 2 \
    --chipset piix3 \
    --ioapic on \
    --rtcuseutc on \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --vram 128 \
    --graphicscontroller vboxsvga \
    --accelerate3d on \
    --pae on \
    --nic1 hostonly \
    --hostonlyadapter1 "vboxnet0" \
    --nic2 nat

# 3. Créer le disque VDI
mkdir -p "$(dirname "$VDI_PATH")"
VBoxManage createmedium disk \
    --filename "$VDI_PATH" \
    --size "$DISK_SIZE" \
    --format VDI \
    --variant Standard

# 4. Contrôleur SATA + disque dur
VBoxManage storagectl "$VM_NAME" \
    --name "SATA Controller" \
    --add sata \
    --controller IntelAhci

VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 0 --device 0 \
    --type hdd \
    --medium "$VDI_PATH"

# 5. Contrôleur IDE + ISO
VBoxManage storagectl "$VM_NAME" \
    --name "IDE Controller" \
    --add ide \
    --controller PIIX3

VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"

echo "✅ VM '$VM_NAME' créée avec succès."
echo "   💡 Après installation Windows, retirez l'ISO avec le script detach-iso.sh"
