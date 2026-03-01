#!/bin/bash
VBoxManage createmedium disk \
    --filename ~/VirtualBox\ VMs/WS22/WS22.vdi \
    --size 50000 \
    --format VDI \
    --variant Standard

VBoxManage storagectl "WS22" --name "IDE Controller" --add ide --controller PIIX3
VBoxManage storageattach "WS22" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$HOME/isooperatingsystem/WS22.iso"

VBoxManage storagectl "WS22" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "WS22" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/home/jukali/VirtualBox VMs/WS22/WS22.vdi"

VBoxManage modifyvm "WS22" \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none


