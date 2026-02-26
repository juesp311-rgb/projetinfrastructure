#!/bin/bash


#Ip de la VM : 10.0.2.15
#users : ubuntuserverweb
Puis :Puis :#Chemin /home/jukali/formationtssr/projetinfrastructure/reseau/ubuntuipstatique.yaml


scp /chemin/vers/ubuntuipstatique.yaml ubuntu@192.168.56.101:/home/ubuntu/

scp /home/jukali/formationtssr/projetinfrastructure/reseau/ubuntuipstatique.yaml ubuntuserverweb@10.0.2.15

ssh ubuntuserverweb@10.0.2.15

Nat avec port forwarding

VBoxManage modifyvm "UbuntuServer" --natpf1 "SSH,tcp,,2222,,22"
ssh ubuntuserverweb@127.0.0.1 -p 2222

# Supprimer l'ancienne clé
ssh-keygen -f '/home/jukali/.ssh/known_hosts' -R '[127.0.0.1]:2222'


ssh -p 2222 ubuntuserverweb@127.0.0.1 "echo 'TON_MDP_VM' | sudo -S mv /tmp/ubuntuipstatique.yaml /etc/netplan/"udo scp -P 2222 /home/jukali/formationtssr/projetinfrastructure/reseau/ubuntuipstatique.yaml ubuntuserverweb@127.0.0.1:/tmp/ && ssh -p 2222 ubuntuserverweb@127.0.0.1 "sudo mv /tmp/ubuntuipstatique.yaml /etc/netplan/"
sudo mv /tmp/ubuntuipstatique.yaml /etc/netplan/

Permissions trop ouverte
sudo chmod 600 /etc/netplan/ubuntuipstatique.yaml
sudo chown root:root /etc/netplan/ubuntuipstatique.yaml

sudo netplan try
sudo netplan apply
└─$ VBoxManage showvminfo "UbuntuServer" | grep -i nat
NIC 1:                       MAC: 08002765F50C, Attachment: NAT, Cable connected: on, Trace: off (file: none), Type: 82540EM, Reported speed: 0 Mbps, Boot priority: 0, Promisc Policy: deny, Bandwidth group: none
    Destination:             File

ip addr show eth0
ping -c 3 192.168.56.1


Probleme connexion ssh probablement a cause de netplan

1️⃣ Vérifier les adaptateurs Host-Only existants
VBoxManage list hostonlyifs


2️⃣ Ajouter la carte Host-Only à ta VM

⚠️ La VM doit être éteinte.

VBoxManage modifyvm "UbuntuServer" --nic3 hostonly --hostonlyadapter3 vboxnet0 --cableconnected3 on
VBoxManage showvminfo "UbuntuServer" | grep -i nic
VBoxManage startvm "UbuntuServer" --type headless
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s9:
      dhcp4: no
      addresses: [192.168.56.10/24]
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]


VBoxManage hostonlyif create
>>VBoxManage hostonlyif create                                                                                    
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Interface 'vboxnet0' was successfully created
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.02️⃣ Ajouter la carte Host-Only à ta VM



VBoxManage modifyvm "UbuntuServer" --nic3 hostonly --hostonlyadapter3 vboxnet0 --cableconnected3 on
VBoxManage showvminfo "UbuntuServer" | grep -i nic2️⃣ Ajouter la carte Host-Only à ta VM

