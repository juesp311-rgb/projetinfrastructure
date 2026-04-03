#!/bin/bash
# Usage: ./detach-iso.sh <nom_vm>

VM_NAME="$1"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <nom_vm>"
    exit 1
fi

echo "⏏️  Retrait de l'ISO de : $VM_NAME"

VBoxManage storageattach "$VM_NAME" \
    --storagectl "IDE Controller" \
    --port 0 --device 0 \
    --type dvddrive \
    --medium none

VBoxManage modifyvm "$VM_NAME" \
    --boot1 disk \
    --boot2 none \
    --boot3 none \
    --boot4 none

echo "✅ ISO retirée, boot sur disque dur activé."
