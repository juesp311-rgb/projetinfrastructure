# Ubunutu : iptables et routage
## 🧱 Architecture proposée avec Linux comme routeur

```
          Linux ROUTEUR
       VLAN20 | 10.10.20.254
       VLAN10 | 10.10.10.254
           |                |
      DC 10.10.20.1       VLAN-20USERS 10.10.10.10
           |                |
      FILE01 / CLIENT01 (VLAN10)
```

- 1️⃣ Créer la VM Linux
	- 2 interfaces réseaux
		- Interface 1 → VLAN20 (réseau interne VirtualBox)
		- Interface 2 → VLAN10 (réseau interne VirtualBox)

- 2️⃣ Configurer les IP statiques

> /etc/netplan/00-installer-config.yaml (Ubuntu 22.04)

```YAML
network:
  version: 2
  renderer: networkd
  ethernets:

    enp0s9:   # Host-Only (optionnel)
      dhcp4: no
      addresses:
        - 192.168.56.10/24
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]

    enp0s3:   # NAT (Internet)
      dhcp4: yes

    enp0s10:  # VLAN10 (Users)
      dhcp4: no
      addresses:
        - 10.10.10.254/24

    enp0s8:   # VLAN20 (DC)
      dhcp4: no
      addresses:
        - 10.10.20.254/24
```

> Puis appliquer :

```bash
sudo netplan apply
```

- 3️⃣ Activer le routage IP

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

> Pour rendre permanent, éditer /etc/sysctl.conf :

```bash
net.ipv4.ip_forward=1
```

> (option internet)*

```bash
sudo iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE
```


- 4️⃣ Configurer iptables pour le NAT / firewall (optionnel en lab)
```
sudo iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
sudo iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

> En lab simple, tu peux juste activer le forwarding, pas besoin de NAT si tout reste en interne.


- 5️⃣ Configurer les VMs Windows

> DC (VLAN20)

```powershell
New-NetIPAddress -InterfaceAlias "VLAN20" -IPAddress 10.10.20.1 -PrefixLength 24 -DefaultGateway 10.10.20.254
Set-NetIPInterface -InterfaceAlias "VLAN20" -Dhcp Disabled
New-NetRoute -InterfaceAlias "VLAN20" -DestinationPrefix 0.0.0.0/0 -NextHop 10.10.20.254

```

> VLAN-20USERS (VLAN10)

```powershell
Get-NetIPAddress -InterfaceAlias "VLAN10" | Remove-NetIPAddress -Confirm:$false
# Supprimer la gateway
Remove-NetRoute -InterfaceAlias "VLAN10" -Confirm:$false
# Configure IP statique
New-NetIPAddress `
  -InterfaceAlias "VLAN10" `
  -IPAddress 10.10.10.10 `
  -PrefixLength 24 `
  -DefaultGateway 10.10.10.254
#Configure le DNS
Set-DnsClientServerAddress `
  -InterfaceAlias "VLAN10" `
  -ServerAddresses 10.10.20.1


```


- 6️⃣ Test

```powershell
ping 10.10.10.254   # Linux routeur
ping 10.10.20.1     # DC
nslookup lab.local

```


- Après redemarrage : failed 
	- probleme au niveau routage linux
```
sudo sysctl net.ipv4.ip_forward
# doit afficher 1 mais affiche 0
```

	- Probleme firewall VLANUSERS

```
# Depuis VLAN-20USERS et DC (Windows)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False


# Autoriser ICMP ping entrant
netsh advfirewall firewall add rule name="Allow ICMPv4" protocol=icmpv4 dir=in action=allow


# Autoriser ICMP ping entrant et sortant
netsh advfirewall firewall add rule name="Allow ICMPv4" protocol=icmpv4 dir=in action=allow
netsh advfirewall firewall add rule name="Allow ICMPv4 Out" protocol=icmpv4 dir=out action=allow



```
- Modificiation fichier pour  Persisistance ipforward = 1
 
```
# creation du dossier mkdir -p sysctl.d
sudo nano /etc/sysctl.d/99-lab-routing.conf
# Uncomment net.ipv4.ip_froward = 1
```

- Pb lors vérification routes 
> la route ne poite pas vers 10.10.10.254 mais sur l'interface Nat
```
# 1️⃣ Supprime route
Get-NetRoute | Where-Object {$_.InterfaceAlias -eq "Ethernet 2"} | Remove-NetRoute -Confirm:$false
- ping Ok

# 2️⃣ Ajouter la route correcte vers ton routeur Linux

New-NetRoute -InterfaceAlias "VLAN10" `
    -DestinationPrefix 0.0.0.0/0 `
    -NextHop 10.10.10.254 `
    -RouteMetric 10





```
Get-NetRoute -AddressFamily IPv4 | Format-Table DestinationPrefix,NextHop,InterfaceAlias,RouteMetric
```
