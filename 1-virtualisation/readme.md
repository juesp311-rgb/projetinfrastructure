# Installation de windows server 2022 (éval)

[Lien Windowsserver eval](https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x>)


## Configuration de Virtualbox
### Vérifie l’ordre de boot

>Avant installation
> Ordre de démarrage (Boot Order) :

- 1. Optical Drive → 2. Hard Disk → 3. Network

>Après l'installation

- 1. Hard Disk → 2. Optical Drive → 3. Network


## Lancer les scripts

- a-registervm.sh
- b-mediumdisk.sh
- c-startvm.sh


## Commandes utiles de Virtualbox

> Liste Vm

```bash
VBoxManage list vms
VBoxManage list runningvms
```

> Check installation

```bash
VboxManage showvminfo "WindowsServer"
VBoxManage showvminfo "WindowsServer2022" --details | grep -A5 "Controller"
VBoxManage showvminfo "WindowsServer2022" --details | grep -A5 "Controller"
VBoxManage showvminfo "WindowsServer2022" | grep Boot
VBoxManage showvminfo "WindowsServer2022" | grep -i iso
VBoxManage showvminfo "WindowsServer2022" | grep Memory
VBoxManage showvminfo "WindowsServer2022" | grep CPUs
```

>SOLVED : Faire storagectl pour créer puis storagattach

> Cas  vm fantôme

```bash
VBoxManage list hdds 
VBoxManage closemedium disk UUID --delete

VBoxManage controlvm "NomDeLaVM" poweroff

VBoxManage storagectl "WindowsServer2022" --name "SATA Controller" --remove
VBoxManage storagectl "WindowsServer2022" --name "IDE Controller" --remove

VBoxManage unregistervm "Windows-server-" --delete
```

#### Alias

> Créer un alias

```bash 
git config --global alias.lg "log --oneline --graph --all --decorate --color"
```
>  Liste alias

```bash
git config --global --get-regexp alias
```

> Vérifie si alias existe

```bash
git config --global --get alias.lg
```

####  VERIFICATION si virtualisation dans BIOS est activé

> si 0 = désactivé

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

> Remplace un mot

```bash
sed -i 's/WindowsServer2022/WS22/g' a-registervm.sh b-mediumdisk.sh c-startvm.sh





