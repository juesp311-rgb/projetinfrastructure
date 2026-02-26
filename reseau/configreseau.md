# Configuration Ip Statique

## Configuration du réseau dans Vbox

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

> Configurer l’IP statique dans Ubuntu Server

```bash
cd /etc/netpan
```

Pour la nouvelle interface (ex. enp0s9) :

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
### Accès à ubuntuserver via SSH

#### ssh ubuntuserverweb@10.0.2.15 ne fonctionne pas 

**Solution proposée**

#### Nat avec port forwarding

```bash
VBoxManage modifyvm "UbuntuServer" --natpf1 "SSH,tcp,,2222,,22"
ssh ubuntuserverweb@127.0.0.1 -p 2222
```

#### Supprimer l'ancienne clé
ssh ubuntuserverweb@10.0.2.15



###Commandes utiles

```bash
VBoxManage showvminfo "WindowsServer2022"
sed -i "s|\$vmName|WindowsServer2022|g" configreseau.sh
VBoxManage modifyvm "WindowsServer2022" --cableconnected1 on
VBoxManage modifyvm "WindowsServer2022" --cableconnected2 on
```



