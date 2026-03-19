*# VLAN20-USERS

## 🏗️ 🧱 ARCHITECTURE

- VM 1 (DC)

	- Rôle : Contrôleur de domaine + DNS

	- IP : 10.10.20.1

	- Réseau : VLAN20

- VM 2 (DC01)

	- Rôle : Routeur

	- IP :

		- VLAN20 → 10.10.20.254

		- VLAN10 → 10.10.10.254

- VM 3 (VLAN-20USERS)

		- Rôle : Clients / tests AD

		- IP : 10.10.10.10




## Pré-requis
### 🖥️ 👉 VM : DC01 (ROUTEUR)

- 1️⃣ Renommer les interfaces (recommandé)

``` Rename-NetAdapter -Name "Ethernet" -NewName "VLAN20"
```

-2️⃣ Configurer les IP

	- Interface VLAN20-RW
> route vers windows


```
New-NetIPAddress `
  -InterfaceAlias "VLAN20-RW" `
  -IPAddress 10.10.20.254 `
  -PrefixLength 24
```

	- Interface VLAN20-R20USERS

> route vers VLAN-20USERS

```
New-NetIPAddress `
  -InterfaceAlias "VLAN20-R20USERS" `
  -IPAddress 10.10.10.254 `
  -PrefixLength 24
```

- 3️⃣ Activer le routage

```
Install-WindowsFeature -Name  RemoteAccess -IncludeManagementTools
Install-WindowsFeature Routing
Install-RemoteAccess -VpnType RoutingOnly > failed
```
```
Get-Service RemoteAccess
Start-Service RemoteAccess




### 🖥️ 👉 VM : DC (Contrôleur de domaine)

- 1️⃣ Ajouter la passerelle
```
Set-NetIPConfiguration `
  -InterfaceAlias "VLAN20" `
  -DefaultGateway 10.10.20.254
```

> 👉 DNS reste :
``` 127.0.0.1 ```
Inst

### 💻 👉 VM : VLAN-20USERS

- Rename-Computer -NewName "VLAN-20USERS" -Restart

```
Rename-Computer -NewName "VLAN-20USERS" -Restart
```


- 1️⃣ Configurer IP + Gateway

```
New-NetIPAddress `
  -InterfaceAlias "VLAN10" `
  -IPAddress 10.10.10.10 `
  -PrefixLength 24 `
  -DefaultGateway 10.10.10.254
```

- 2️⃣ Configurer DNS

``` 
Set-DnsClientServerAddress `
  -InterfaceAlias "VLAN10" `
  -ServerAddresses 10.10.20.1
```


- 🧪 TESTS

```
ping 10.10.10.254   # DC01
ping 10.10.20.1     # DC
nslookup lab.local
```




