#!/bin/bash
VBoxManage createvm \
    --name "VLAN20-USERS" \
    --ostype "Windows2022_64" \
    --register

VBoxManage modifyvm "VLAN20-USERS" \
    --memory 4096 \
    --cpus 2 \
    --chipset piix3 \
    --ioapic on \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --rtcuseutc on \
    --nic1 nat \
    --vram 128 \
    --graphicscontroller vboxsvga \
    --accelerate3d on
  
VBoxManage modifyvm "VLAN20-USERS" --pae on
