#####Installation de windows server 2022 (éval)#####

Lien du fichier : 
https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_fr-fr.iso


#Pré-requis
Nom Vm : WindowsServer2022
Utiliateur : 
Mdp : 
cd Virtualbox Vms (vérifier si il n'y a pas de VM existante)

#VERIFICATION si virtualisation dans BIOS est activé
#si 0 = désactivé
egrep -c '(vmx|svm)' /proc/cpuinfo
              
#Voir si state fantôme
vboxmanage list hdds | grep State

Remplace l'ancien nom par ule nouveau nom de la vm dans les scripts
sed -i 's/WindowsServer2022/WS22/g' a-registervm.sh b-mediumdisk.sh c-startvm.sh

###Configuration de Virtualbox
#Vérifie l’ordre de boot
Configuration → Système → Carte mère
Contrôleur PIIX3 (IDE) → ton ISO Windows Server 2022
Contrôleur SATA → ton disque dur (.vdi)


Rappel Configuration : 
Processeur : activer PAE/NX
Vidéo memoire : 128

#Lancer les scripts
a-registervm.sh
b-mediumdisk.sh
c-startvm.sh


#Après installation (important)
Une fois Windows installé :
Désactiver le Lecteur optique et mettre Disque dur en premier



###Commandes utiles de Virtualbox
#Liste Vm
VBoxManage list vms
VBoxManage list runningvms


#Check installation
VBoxManage showvminfo "WindowsServer2022"
VBoxManage showvminfo "WindowsServer2022" --details | grep -A5 "Controller"
VBoxManage showvminfo "WindowsServer2022" --details | grep -A5 "Controller"
VBoxManage showvminfo "WindowsServer2022" | grep Boot
VBoxManage showvminfo "WindowsServer2022" | grep -i iso
VBoxManage showvminfo "WindowsServer2022" | grep Memory
VBoxManage showvminfo "WindowsServer2022" | grep CPUs


SOLVED : Faiire storagectl pour créer puis storagattach

#List vm fantôme
VBoxManage list hdds 
VBoxManage closemedium disk UUID --delete

VBoxManage controlvm "NomDeLaVM" poweroff

VBoxManage storagectl "WindowsServer2022" --name "SATA Controller" --remove
VBoxManage storagectl "WindowsServer2022" --name "IDE Controller" --remove

VBoxManage unregistervm "Windows-server-" --delete



###Alias
#Ajoute un alias 
git config --global alias.lg "log --oneline --graph --all --decorate --color"

#Liste alias
git config --global --get-regexp alias

#Vérifie si alias existe
git config --global --get alias.lg







