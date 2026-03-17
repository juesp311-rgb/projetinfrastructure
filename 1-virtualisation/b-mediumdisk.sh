#!/bin/bash
VBoxManage createmedium disk \
    --filename ~/VirtualBox\ VMs/CLIENT01/CLIENT01.vdi \
    --size 50000 \
    --format VDI \
    --variant Standard

VBoxManage storagectl "CLIENT01" --name "IDE Controller" --add ide --controller PIIX3
VBoxManage storageattach "CLIENT01" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$HOME/isooperatingsystem/CLIENT01.iso"

VBoxManage storagectl "CLIENT01" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "CLIENT01" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/home/jukali/VirtualBox VMs/CLIENT01/CLIENT01.vdi"

VBoxManage modifyvm "CLIENT01" \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none


