# Configuration Ip Statique Ubuntu

## Configuration du réseau dans Vbox

### Accès à ubuntuserver via SSH
#### Connexion en Nat avec port forwarding

> Supprimer l'ancienne clé ssh

```bash
ssh-keygen -f '/home/jukali/.ssh/known_hosts' -R '[127.0.0.1]:2222'
```
> Configurer port 2222 dans Vbox
```bash
VBoxManage modifyvm "UbuntuServer" --natpf1 "SSH,tcp,,2222,,22"
```

> Lancer ssh (failed)

```bash
ssh ubuntuserverweb@127.0.0.1 -p 2222


** Solution proposée **

### Ajout d'un adatptateur host-only

> Vérifier les adaptateurs Host-Only existants
```bash
VBoxManage list hostonlyifs
```

> Créer le Host-Only Adapter

```bash
VBoxManage hostonlyif create
```
>  Configurer l’IP du Host-Only Adapter

```bash 
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
```

> Ajouter la carte Host-Only à la VM

```bash 
VBoxManage modifyvm "UbuntuServer" --nic3 hostonly --hostonlyadapter3 vboxnet0 --cableconnected3 on
```

> Vérifier
```bash
VBoxManage showvminfo "UbuntuServer" | grep -i nic
```
### Identifier l'addresse mac de l'adaptateur host-only

> Configurer l'interface de la VM qui à la meme adresse mac que l'adaptateur host-only
>
>> ```bash
>
>> sudo ip addr flush dev enp0s8
>
>> sudo ip addr add 192.168.56.10/24 dev enp0s9
>
>>sudo ip link set enp0s8 up
```
### Se connecter à la vm via ssh pour le transfert de fichier

```bash
ssh ubuntuserverweb@192.168.10.10 (de kali)
```

#### Vérification de l'adresse MAC Host-only enps09

```bash
ip a show
ip link show
```


### Configuration IP statique

>Ouvrir le fichier netplan

```bash
cd /etc/netplan
sudo chmod u+x ubuntuipstatique.yaml
```
> Configuration du fichier ubuntustatiqueip.yaml

```bash 

network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s9:                     # Host-Only
      dhcp4: no
      addresses:
        - 192.168.56.10/24
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]

    enp0s8:                     # Internal Network
      dhcp4: no
      addresses:
        - 192.168.10.10/24
      # pas de gateway
```

> Supprime gateway4 pour enp0s9 → plus de warning
>
> Internal Network enp0s8 → IP statique 192.168.10.10

> Appliquer la configuration netplan
>
> sudo chmod 600 /etc/netplan/ubuntuipstatique.yaml
>
> sudo netplan apply
`

** Connextion SSH : enps09 **
** IP statique reseau interne : enps08 **



# Configuration CentosBdd (ssh + ip statique)
## Accès Centosbdd via ssh


enps09 : host-only : ssh : 192.168.56.20
enps08 : reseau interne : 192.168.10.11

users : centosbdd


### Vérifier IP de CentosBdd

```bash
sudo systemctl status sshd
```

### Installation, enable, start sshd
```bash
sudo systemctl enable sshd --now
```

### Ajout d'un adatptateur host-only

> Vérifier les adaptateurs Host-Only existants
```bash
VBoxManage list hostonlyifs
```

> Créer le Host-Only Adapter

```bash
VBoxManage hostonlyif create
```
>  Configurer l’IP du Host-Only Adapter

```bash 
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
```

> Ajouter la carte Host-Only à la VM

```bash 
VBoxManage modifyvm "centosbdd" --nic3 hostonly --hostonlyadapter3 vboxnet0 --cableconnected3 on
```

> Vérifier
```bash
VBoxManage showvminfo "centosbdd" | grep -i nic

#### Atttribue IP à l'insterface enps09 qui a la même **  MAC **  adresse que vboxnet0

> ** Réinitailise et configure interface : **
>
>> ```bash
>
>> sudo ip addr flush dev enp0s8
>
>> sudo ip addr add 192.168.56.10/24 dev enp0s9
>
>>sudo ip link set enp0s8 up
```

ou


> Créer une connexion host-only enps09

```bash
sudo nmcli con add type ethernet con-name hostonly ifname enp0s9 ipv4.method manual ipv4.addresses 192.168.56.10/24
sudo nmcli con up hostonly
```

> Créer une connexion reseau interne (enps08)

```bash 
sudo nmcli con add type ethernet con-name internal ifname enp0s8 ipv4.method manual ipv4.addresses 192.168.10.11/24
sudo nmcli con up internal
```

> Vérifier interface

```bash
ip a
nmcli con show
```

> Désactiver le firewall (optionnel)

```bash
sudo systemctl status firewalld
sudo systemctl stop firewalld
```

** Ping ok **

> @ WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED! 
>
>>Solution
>
>>  Pour voir l’entrée existante :
>
>> ```bash 
>
>>ssh-keygen -F 192.168.56.10
>
>> Pour supprimer l’ancienne clé :
>
>>```bash
>
>>ssh-keygen -R 192.168.56.10
>
>> ssh centosbdd@192.168.56.10
>
>>```

** connexion ssh **



>Commande utile 
Vérifier si l'adresse est statique
```bash
nmcli con show internal | grep ipv4.method
nmcli con show hostonly | grep ipv4.method
```

> Reconnecte
>
>>ssh centosbdd@192.168.56.10







# Configuration Windows server 2022 (eval)

```bash 
wsl --install
```

## Configuration Virtualbox

###  interface Nat 

###  interface reseau interne

###  interface host-only pour activer ssh

> Activer NIC 3 et le rattacher au host-only

```bash
VBoxManage modifyvm "WindowsServer" --nic3 hostonly
VBoxManage modifyvm "WindowsServer" --hostonlyadapter3 vboxnet0
VBoxManage modifyvm "WindowsServer" --cableconnected3 on
```


## Interface réseau

> Carte Ethernet : 10.0.2.15 (NAT)
> Carte Ethernet 2 : 169.254.183.239 (reseau interne)
> Carte Ethernet 3 : 192.168.56.101 (host-only)



## Connexion SSH

>Installer le serveur OpenSSh

```bash
 Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```
> Vérifier l’installation

```bash
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
```

> Démarrer et activer le service SSH

```bash
Start-Service sshd
> ou de manière automatic
Set-Service -Name sshd -StartupType Automatic
```

> Vérifier que SSH fonctionne
```bash
Get-Service -Name sshd
```

> Vérifier que le port 22 est à l'écoute

```bash
netstat -an | findstr :22
```

> Teste la connexion locale (depuis le serveur) :

```bash
ssh localhost
``` 


## Ip statique

>Vérifier le nom exact de l’interface

```bash 
Get-NetAdapter
```

> Supprimer toute configuration IP existante (optionnel mais recommandé)

```bash
Remove-NetIPAddress -InterfaceAlias "Ethernet2" -Confirm:$false
```

> Configurer une IP statique

```bash

> New-NetIPAddress -InterfaceAlias "Ethernet2" -IPAddress 192.168.10.12 -PrefixLength 24 -DefaultGateway 192.168.10.1
```

> Configurer le server DNS

```bash
Set-DnsClientServerAddress -InterfaceAlias "Ethernet2" -ServerAddresses ("8.8.8.8","8.8.4.4")
```

> Vérifier la configuration 

```bash
Get-NetIPAddress -InterfaceAlias "Ethernet2"
Get-DnsClientServerAddress -InterfaceAlias "Ethernet2"
```
** Cela montre l’IP, le masque, la passerelle et les DNS configurés.**


># ===============================
>
># Configuration IP statique pour Ethernet2
>
># ===============================
>
># Paramètres réseau à modifier
>
>$InterfaceName = "Ethernet2"
>
>$IPAddress      = "192.168.10.50"      # IP souhaitée
>
>$PrefixLength   = 24                    # Masque en CIDR (24 = 255.255.255.0)
>
>$Gateway        = "192.168.10.1"       # Passerelle
>
>$DNSServers     = @("8.8.8.8","8.8.4.4") # DNS (ici Google, à adapter)
>
>
>
># -------------------------------
>
># Étape 1 : Supprimer toute IP existante (optionnel mais recommandé)
>
># -------------------------------
>
>Write-Host "Suppression des IP existantes sur $InterfaceName..."
>
>Get-NetIPAddress -InterfaceAlias $InterfaceName -AddressFamily IPv4 | Remove-NetIPAddress -Confirm:$false
>
>
>
># -------------------------------
>
># Étape 2 : Ajouter la nouvelle IP statique
>
># -------------------------------
>
>Write-Host "Ajout de l'IP statique $IPAddress/$PrefixLength avec passerelle $Gateway..."
>
>New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway
>
>
>
>
>
>#-------------------------------
>
># Étape 3 : Configurer les serveurs DNS
>
># -------------------------------
>
>Write-Host "Configuration des serveurs DNS : $($DNSServers -join ', ')..."
>
>Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $DNSServers
>
>
>
># -------------------------------
>
># Étape 4 : Vérifier la configuration
>
># -------------------------------
>
>Write-Host "Configuration réseau actuelle pour $InterfaceName :"
>
>Get-NetIPAddress -InterfaceAlias $InterfaceName
>
>Get-DnsClientServerAddress -InterfaceAlias $InterfaceName
>
>
>
>Write-Host "✅ Configuration IP statique terminée !"




