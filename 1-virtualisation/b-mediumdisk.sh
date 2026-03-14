#!/bin/bash
VBoxManage createmedium disk \
    --filename ~/VirtualBox\ VMs/WindowsServer2022/WindowsServer2022.vdi \
    --size 50000 \
    --format VDI \
    --variant Standard

VBoxManage storagectl "WindowsServer2022" --name "IDE Controller" --add ide --controller PIIX3
VBoxManage storageattach "WindowsServer2022" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "$HOME/isooperatingsystem/WindowsServer2022.iso"

VBoxManage storagectl "WindowsServer2022" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "WindowsServer2022" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/home/jukali/VirtualBox VMs/WindowsServer2022/WindowsServer2022.vdi"

VBoxManage modifyvm "WindowsServer2022" \
--boot1 dvd \
--boot2 disk \
--boot3 none \
--boot4 none


