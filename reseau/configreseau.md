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
```

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
```bash
 sudo ip addr flush dev enp0s8
 sudo ip addr add 192.168.56.10/24 dev enp0s9
 git commit -m "Résolution des conflits"sudo ip link set enp0s8 up
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

> Appliquer la configuration netplan
```bash
sudo chmod 600 /etc/netplan/ubuntuipstatique.yaml
sudo netplan apply
```

** Connextion SSH : enps09 **
** IP statique reseau interne : enps08 **



# Configuration CentosBdd (ssh + ip statique)
## Accès Centosbdd via ssh

> enps09 : host-only : ssh : 192.168.56.20
> users : centosbdd


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
```


#### Atttribue IP à l'insterface enps09 qui a la même **  MAC **  adresse que vboxnet0

** Réinitailise et configure interface : **

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

## Configuration Virtualbox

- interface Nat 
- Ethernet 2 : reseau interne
- Ethernet 3 : host-only

###  interface host-only pour activer ssh

> Activer NIC 3 et le rattacher au host-only

```bash
VBoxManage modifyvm "WindowsServer" --nic3 hostonly
VBoxManage modifyvm "WindowsServer" --hostonlyadapter3 vboxnet0
VBoxManage modifyvm "WindowsServer" --cableconnected3 on
```

## Connexion ssh 
Vérification mac du port de l'hôte et windows

## Ip statique

- ubuntuserverweb : 192.168.10.10
- centosbdd : 192.168.10.11
- windowsserver2022 : 192.168.10.12 

# Vérifier le reseau interne

**  VM : IP dans le même subnet pour le réseau interne **

> ubuntuserverweb : 192.168.10.10
>
>> inet 192.168.10.10
>
>> netmask 255.255.255.0
>
>> broadcast 192.168.10.255
 
> windowsserver20222 :
>
>> Adresse IPv4. . . . . . . . . . . . . .: 192.168.10.12
>
>> Masque de sous-réseau. . . . . . . . . : 255.255.255.0
> 
>> Passerelle par défaut. . . . . . . . . : 192.168.10.1



> centosbdd :  inet 192.168.10.11/24 brd 192.168.10.255 
>
>> inet 192.168.10.11
> 
>> netmask 255.255.255.0 
>
>> broadcast 192.168.10.255

## Véfication ssh

> ssh ubuntuserverweb@192.168.56.10                                                                               
> ssh centosbdd@192.168.56.11 
> ssh Administrateur@192.168.56.12


### Vérification reseau interne

> nom du reseau : reseauInterne

```bash
Depuis ubuntu, ping windows et centos ok
```



| VM                  | Interface          | IP            | Réseau         |
|--------------------|-----------------|---------------|----------------|
| Kali (Hôte)        | Host-Only vbox0  | 192.168.56.1  | Host-Only      |
|
| Ubuntu Server      | enp0s9           | 192.168.56.10 | Host-Only      |
|                    | enp0s8           | 192.168.10.10 | InternalNet    |
|
| CentOS BDD         | enp0s9           | 192.168.56.11 | Host-Only      |
|                    | enp0s8           | 192.168.10.11 | InternalNet    |
|
| Windows Server 2022| Host-Only        | 192.168.56.12 | Host-Only      |
|                    | Ethernet2        | 192.168.10.12 | InternalNet    |
