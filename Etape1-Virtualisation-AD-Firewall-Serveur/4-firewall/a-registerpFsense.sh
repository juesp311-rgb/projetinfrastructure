#!/bin/bash

VM_NAME="pfSense-Firewall"

# 1️⃣ Créer la VM
VBoxManage createvm \
    --name "$VM_NAME" \
    --ostype "FreeBSD_64" \
    --register

# 2️⃣ Configurer la VM
VBoxManage modifyvm "$VM_NAME" \
    --memory 4096 \
    --cpus 2 \
    --chipset piix3 \
    --ioapic on \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --rtcuseutc on \
    --vram 16 \
    --graphicscontroller vboxvga \
    --nic1 natnetwork \
    --nat-network1 "NAT-EXT" \
    --nic2 intnet \
    --intnet2 "DMZ" \
    --nic3 intnet \
    --intnet3 "LAN" \
    --pae on
