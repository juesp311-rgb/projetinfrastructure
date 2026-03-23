# routage, segmentation, IP forwarding)

## Ubuntu

-✅ Architecture Réseau

```
| Interface       | IP           | Rôle            |
| --------------- | ------------ | --------------- |
| enp0s8          | 10.10.20.254 | vers DC         |
| enp0s3 OU autre | 10.10.30.1   | vers VLAN USERS |

```


- 🔧 Flush des routes
```
 sudo ip route flush table main
```

- Réassigner les IP proprement

```
sudo ip addr flush dev enp0s3
sudo ip addr flush dev enp0s8

sudo ip addr add 10.10.30.1/24 dev enp0s3
sudo ip addr add 10.10.20.254/24 dev enp0s8

sudo ip link set enp0s3 up
sudo ip link set enp0s8 up
```

- 🔥 Active le routage 

```
sudo sysctl -w net.ipv4.ip_forward=1
```

- 🔥Règles firewall

```
sudo iptables -A FORWARD -i enp0s8 -o enp0s10 -j ACCEPT
sudo iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT
```


## Configuration VLAN-20USers

```
Get-NetAdpater
Rename-NetAdapter -Name "Ethernet" -NewName "VLAN20"

Remove-NetIPAddress -InterfaceAlias "VLAN20" -Confirm:$false -ErrorAction SilentlyContinue

New-NetIPAddress -InterfaceAlias "VLAN20" -IPAddress 10.10.30.10 -PrefixLength 24 -DefaultGateway 10.10.30.1

Set-DnsClientServerAddress -InterfaceAlias "VLAN20" -ServerAddresses 10.10.20.1```

## Configuration Netplan




# Aller plus loin 
Je peux t’aider à :

ajouter NAT pour Internet
faire du vrai VLAN tagging (802.1Q)
ajouter DHCP sur Ubuntu
ou transformer ton lab en infra AD complète


