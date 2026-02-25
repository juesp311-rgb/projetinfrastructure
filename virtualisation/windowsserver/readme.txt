Revenir au code d'un fichier supprimé
git checkout uid nom.du.fichier

Visualise un fichier
git show + uudi (donné par le git lg)

 

Change l'ancien nom et chemin d'accès de l'iso  en nouveau nom

Check cd isooperatingsystem et cd Virtualbox Vms


sed -i 's/WindowsServer2022/WS22/g' a-registervm.sh b-mediumdisk.sh c-startvm.sh



2️⃣ Vérifie l’ordre de boot

Configuration → Système → Carte mère

Lecteur optique (PIIX3) VID ISO

Disque dur (VDI°


    Contrôleur SATA → ton disque dur (.vdi)

    Contrôleur PIIX3 (IDE) → ton ISO Windows Server 2022

🚀 Étapes finales pour démarrer l’installation


Rappel Configuration : 
Processeur : activer PAE/NX
Sockage Stata Controller :
Avant installation activer 
Sata Controler
IDE
1-Optical drive PIX3 : fichier.iso 
2-Hard disk : fichier.vdi
après l'installation supprimer Optical drive et selectionné Hard drive premier hard disk




💾 Après installation (important)

Une fois Windows installé :

❌ Désactiver le Lecteur optique ou

Mettre Disque dur en premier


CODE

sed -i 's/WindowsServer2022/WS22/g' storagectl.sh 



Nom de la VM :WindowsServer2022

VERIFICATION avant le début de l'installation
egrep -c '(vmx|svm)' /proc/cpuinfo
              vérifier si virtualisation dans BIOS est bien activé.
                si 0 = désactivé
ls -lh $HOME/isooperatingsystem/WindowsServer2022.iso

VBoxManage list vms
vboxmanage list hdds | grep State
 
          voir state fantôme

A la fin de l'installation
VBoxManage showvminfo "WindowsServer2022"
VBoxManage showvminfo "WindowsServer2022" --details | grep -A5 "Controller"
VBoxManage showvminfo "WindowsServer2022" --details | grep -A5 "Controller"
VBoxManage showvminfo "WindowsServer2022" | grep Boot
VBoxManage showvminfo "WindowsServer2022" | grep -i iso
VBoxManage showvminfo "WindowsServer2022" | grep Memory
VBoxManage showvminfo "WindowsServer2022" | grep CPUs


SOLVED : Faiire storagectl pour créer puis storagattach


VBoxManage list vms
VBoxManage list runningvms

VBoxManage list hdds
VBoxManage closemedium disk UUID --delete



VBoxManage controlvm "NomDeLaVM" poweroff

VBoxManage storagectl "WindowsServer2022" --name "SATA Controller" --remove
VBoxManage storagectl "WindowsServer2022" --name "IDE Controller" --remove
VBoxManage unregistervm "Windows-server-" --delete



Liste alias
git config --global --get-regexp alias
Vérifie si alias existe
git config --global --get alias.lg
Ajuote un alias 
git config --global alias.lg "log --oneline --graph --all --decorate --color"
