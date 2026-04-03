# pfsense

## Configuration idéale complète (DMZ incluse)

- Dans VirtualBox → VM pfSense → Réseau :

```
Adapter 1 (WAN)
Mode : Accès par pont (Bridged)
Carte réseau : ta carte physique (Ethernet/WiFi)

👉 Permet à pfSense d’avoir Internet directement

Adapter 2 (LAN)
Mode : Host-Only Adapter
Réseau : vboxnet0

👉 Réseau interne pour tes VM clients

Adapter 3 (DMZ)
Mode : Host-Only Adapter (ou Internal Network)
Réseau : vboxnet1 (ou nom DMZ)

👉 Réseau isolé pour serveurs DMZ

```

- Architecture

```
Internet (bridge)
        ↓
      WAN (pfSense)
     /          \
   LAN         DMZ
```


## Configuration interface 

#### 6. Points clés / pièges évités

- Ne pas mettre LAN et WAN sur le même réseau
- LAN en IP statique obligatoire pour AD
- DHCP LAN configuré pour VM clientes
- IPv6 ignoré pour simplifier le lab
- WebConfigurator en HTTPS sécurisé



- 🔹 1. Affectation des interfaces
	- Menu principal → 1 : Assign Interfaces
	- Ne pas configurer de VLAN → n
	- Assignation des interfaces :

```

Rôle	Interface
WAN	em0
LAN	em1
OPT1	em2

```

> Note : em0 en bridge (WAN), em1 en Host-Only (LAN), em2 pour DMZ

- 🔹 2. Configuration de l’IP LAN

```
Menu principal → 2 : Set interface IP addresses
LAN : IP statique → 192.168.10.10
Subnet mask → 24 (255.255.255.0)
Gateway LAN → Enter (aucune)
Activer DHCP LAN → y
Plage : 192.168.10.100 → 192.168.10.200

```
> WAN reste en DHCP (bridge vers ton réseau réel)


- 🔹 3. IPv6 LAN

```
pfSense demande : configurer IPv6 → n
On n’utilise que IPv4 pour ce lab

```


- 🔹 4. WebConfigurator Protocol

``` 
pfSense propose HTTP ou HTTPS → n pour rester en HTTPS
Interface web disponible sur : https://192.168.10.10

```


- 5. Vérifications / test console

LAN disponible dans console :

```

LAN (em1) -> 192.168.10.10
WAN (em0) -> DHCP (bridge)
OPT1 (em2) -> non configuré

```

Depuis une VM LAN (SRV-AD-01) :

```

ping 192.168.10.10  # vers pfSense
ping 8.8.8.8        # Internet via WAN pfSense

```

Configuration SRV-AD-01 IP :

```

IP : 192.168.10.20
Subnet : 255.255.255.0
Gateway : 192.168.10.10
DNS : 192.168.10.10

```









## Création de ta VM Windows Server

- ⚙️ 1. Vérifier et renommer l’adaptateur réseau

```
Get-NetAdapter
Rename-NetAdapter -Name "Ethernet" -NewName "LAN"

```
- 🌐 2. Configurer IP statique

```
New-NetIPAddress `
-InterfaceAlias "LAN" `
-IPAdress 192.168.10.20 `
-PrefixLength 24 `
-DefaultGateway 192.168.10.10
```

> 🔹 Supprimer DHCP (si actif)
>
>> ``` Set-NetIPInterface -InterfaceAlias "LAN" -Dhcp Disabled ```


- 🔹 Config DNS (IMPORTANT)
> 👉 Avant AD, tu peux temporairement mettre pfSense :

```

Set-DnsClientServerAddress `
-InterfaceAlias "LAN" `
-ServerAddresses 192.168.10.10

```

- 🧪 3. Tests réseau

```

ping 192.168.10.10
ping 8.8.8.8

```
> ✔ Si OK → réseau fonctionnel

- 🧱 5. Installer Active Directory + DNS

```

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

```

- 🌳 6. Créer le domaine (forest)

```
Install-ADDSForest `
-DomainName "corp.local" `
-DomainNetbiosName "CORP" `
-InstallDNS `
-SafeModeAdministratorPassword (Read-Host -AsSecureString "Mot de passe DSRM")

```

> Mot de passe DSRM : Test1232X


- 🔁 7. Après reboot (IMPORTANT)

	- 🔹 Corriger DNS

> Maintenant le serveur est DNS → il doit pointer sur lui-même :


```

Set-DnsClientServerAddress `
-InterfaceAlias "LAN" `
-ServerAddresses 127.0.0.1

```


- 🧪 8. Vérification AD

```

Get-ADDomain

```

> 👉 Doit afficher :
> 
>> corp.local
>


- 🧠 ⚠️ Pièges critiques

```
❌ 1. DNS mal configuré

👉 Si tu laisses pfSense en DNS après AD → domaine cassé
❌ 2. IP en DHCP

👉 Un contrôleur AD DOIT être statique

❌ 3. Nom du serveur après AD

👉 Toujours renommer AVANT d’installer AD

❌ 4. Pas de communication avec pfSense

👉 Vérifier ping avant installation

```

- 🧱 Résultat final

```

| Élément     | Valeur        |
| ----------- | ------------- |
| Nom serveur | SRV-AD-01     |
| IP          | 192.168.10.20 |
| Gateway     | 192.168.10.10 |
| DNS         | 127.0.0.1     |
| Domaine     | corp.local    |


```

- 🚀 Prochaine étape

> 👉 Une fois AD installé, tu pourras :


	- Joindre un client Windows au domaine
	- Créer des utilisateurs
	- Configurer GPO
	- Connecter la DMZ


## Configure Windows10

