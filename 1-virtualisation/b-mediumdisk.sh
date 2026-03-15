#!/bin/bash
VBoxManage createmedium disk \
    --filename ~/VirtualBox\ VMs/FILE01/FILE01.vdi \
    --size 50000 \
    --format VDI \
    --variant Standard

VBoxManage storagectl "FILE01" --name "IDE Controller" --add ide --controller PIIX3
VBoxManage storageattach "FILE01" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$HOME/isooperatingsystem/FILE01.iso"

VBoxManage storagectl "FILE01" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "FILE01" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/home/jukali/VirtualBox VMs/FILE01/FILE01.vdi"

VBoxManage modifyvm "FILE01" \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none


