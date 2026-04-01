#!/bin/bash
# Script pour créer une VM pfSense avec DMZ + LAN dans VirtualBox

# Nom de la VM
VM_NAME="pfSense-Firewall"

# Chemin ISO pfSense (décompressé)
ISO_PATH="$HOME/Downloads/pfSense-CE-2.8.2-RELEASE-amd64.iso"

# Création VM
VBoxManage createvm --name "$VM_NAME" --ostype FreeBSD_64 --register

# Mémoire et CPU
VBoxManage modifyvm "$VM_NAME" --memory 4096 --cpus 2

# Disque dur
VBoxManage createmedium disk --filename "$HOME/VirtualBox VMs/$VM_NAME.vdi" --size 20000
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$VM_NAME.vdi"

# Ajouter ISO pfSense
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH"

# Configuration réseau
# Carte 1 - WAN (NAT Network)
VBoxManage modifyvm "$VM_NAME" --nic1 natnetwork --nat-network1 "NAT-EXT" --cableconnected1 on
# Carte 2 - DMZ (Internal Network)
VBoxManage modifyvm "$VM_NAME" --nic2 intnet --intnet2 "DMZ" --cableconnected2 on
# Carte 3 - LAN (Internal Network)
VBoxManage modifyvm "$VM_NAME" --nic3 intnet --intnet3 "LAN" --cableconnected3 on

# Affichage
VBoxManage modifyvm "$VM_NAME" --vram 16

# Démarrer la VM
VBoxManage startvm "$VM_NAME"
