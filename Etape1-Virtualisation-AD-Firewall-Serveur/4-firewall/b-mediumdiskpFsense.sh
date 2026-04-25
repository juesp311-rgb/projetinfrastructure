#!/bin/bash

VM_NAME="pfSense-Firewall"
VDI_PATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
ISO_PATH="$HOME/isooperatingsystem/$VM_NAME.iso"

# Créer le dossier pour le disque si nécessaire
mkdir -p "$(dirname "$VDI_PATH")"

# Créer le disque dur
VBoxManage createmedium disk --filename "$VDI_PATH" --size 20000

# Ajouter le contrôleur SATA et attacher le disque dur
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 0 --device 0 \
    --type hdd \
    --medium "$VDI_PATH"

# Ajouter le contrôleur IDE et attacher l'ISO pfSense
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide
VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"

echo "Disque et ISO attachés à la VM $VM_NAME."
