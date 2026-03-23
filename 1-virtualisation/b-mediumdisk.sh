#!/bin/bash

VM_NAME="VLAN20-USERS"
VDI_PATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"
ISO_PATH="$HOME/isooperatingsystem/VLAN20-USERS.iso"


# 3️⃣ Créer le disque dur VDI
mkdir -p "$(dirname "$VDI_PATH")"
VBoxManage createmedium disk \
    --filename "$VDI_PATH" \
    --size 50000 \
    --format VDI \
    --variant Standard

# 4️⃣ Ajouter contrôleur SATA et attacher le disque dur
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "$VDI_PATH"

# 5️⃣ Ajouter contrôleur IDE et attacher le DVD (ISO)
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide --controller PIIX3
VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$ISO_PATH"





VBoxManage modifyvm "VLAN20-USERS" \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none


