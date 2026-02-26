#!/bin/bash

# Configurer l’adaptateur 1 en NAT
VBoxManage modifyvm "WindowsServer2022" --nic1 nat


# Configurer l’adaptateur 2 en Réseau interne
VBoxManage modifyvm "WindowsServer2022" --nic2 intnet --intnet2 "reseauSI"

# Vérifier la configuration
VBoxManage showvminfo "WindowsServer2022"

#Changer
#VBoxManage showvminfo "WindowsServer2022"
#sed -i "s|\$vmName|WindowsServer2022|g" configreseau.sh
#VBoxManage modifyvm "WindowsServer2022" --cableconnected1 on
#VBoxManage modifyvm "WindowsServer2022" --cableconnected2 on
