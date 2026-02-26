# Configuration Ip Statique

## Configuration du réseau dans Vbox
> Supprimer l'ancienne clé ssh

```bash
ssh-keygen -f '/home/jukali/.ssh/known_hosts' -R '[127.0.0.1]:2222'
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



###  Configurer l’IP statique dans Ubuntu Server
#### Connexion SSH via host-only

```bash
ssh ubuntuserverweb@192.168.56.10
```


```bash
cd /etc/netpan
```

Pour la nouvelle interface host-only (ex. enp0s9) :

```bash 
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s9:
      dhcp4: no
      addresses: [192.168.56.10/24]
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

Puis :

```bash
sudo chmod 600 /etc/netplan/ubuntuipstatique.yaml
sudo netplan apply
```
```

** Connextion SSH et configuration ip statique sur l'interface enps09 **


###Commandes utiles

```bash
VBoxManage showvminfo "WindowsServer2022"
sed -i "s|\$vmName|WindowsServer2022|g" configreseau.sh
VBoxManage modifyvm "WindowsServer2022" --cableconnected1 on
VBoxManage modifyvm "WindowsServer2022" --cableconnected2 on
```



