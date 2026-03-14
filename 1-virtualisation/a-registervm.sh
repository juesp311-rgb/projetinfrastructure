#!/bin/bash
VBoxManage createvm \
    --name "WindowsServer2022" \
    --ostype "Windows2022_64" \
    --register

VBoxManage modifyvm "WindowsServer2022" \
    --memory 8192 \
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
  
VBoxManage modifyvm "WindowsServer2022" --pae on
