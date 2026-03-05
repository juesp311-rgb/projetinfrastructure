# Active Directory Home Lab (System Admnistration)
```
Infrastructure
│
├── network
│   ├── vlan-plan.md
│   ├── ip-addressing.md
│
├── active-directory
│   ├── ou-structure.md
│   ├── gpo-security.md
│
└── diagrams
    ├── network-datacenter.png

```

- Configuration IP du serveur
	- exemple pour ton DC

```powershell
New-NetIPAddress `
-InterfaceAlias "Ethernet" `
-IPaddress 10.10.10.10 `
-PrefixLength 24 `
-DefaultGateway 10.10.10.1
```
	- DNS (vers lui-même) :
```powershell
Set-DnsClientServerAddress `
-InterfaceAlias "Ethernet" `
-ServerAddresses ("127.0.0.1")
```

- Installer Active Directory
```bash 
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

- Créer la forêt et le domaine
	- Forest : corptech.com
	- Domain : ad.corptech.com

```powershell 
Install-ADDSForest `
-DomainName "ad.corptech.com" `
-DomainNetbiosName "CORPTECH" `
-InstallDns `
-SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM Password") `
-Force```

**Le serveur va créer la forêt, créer le domaine, installer DNS, devenir Domain Controller, puis redémarrer**


- Installer DHCP
```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
```

- Autoriser DHCP dans Active Directory
```powershell 
Add-DhcpServerInDC `
-DnsName "dc01.ad.corptech.com" `
-IPaddress 10.10.10.10
```

⚠️ Important : seul un serveur DHCP autorisé dans AD peut distribuer des IP.

C’est une sécurité entreprise contre les rogue DHCP.


- Vérifier
```powershell
Get-DhcpServerInDC
```

- Résultat attendu :
> dc01.ad.corptech.com   10.10.10.10


- ⭐ Architecture du  lab
```
CorpTech Infrastructure
│
├── Forest : corptech.com
│
└── Domain : ad.corptech.com
      │
      ├── DC01 (10.10.10.10)
      │      AD DS
      │      DNS
      │      DHCP
      │
      ├── FILE01 (10.10.10.20)
      │
      └── WSUS01 (10.10.10.30)
```

# Dans VirtualBox, crée 2 VM :

- FILE01
```
Nom : FILE01
OS : Windows Server
RAM : 4 GB
Disque : 100 GB
Réseau : VLAN10 (Serveurs)
```
- WSUS01
```
Nom : WSUS01
OS : Windows Server
RAM : 4 GB
Disque : 120 GB
Réseau : VLAN10
```

- Configurer l’IP (PowerShell)
>- FILE01
```powershell
New-NetIPAddress `
-InterfaceAlias "Ethernet" `
-IPaddress 10.10.10.20 `
-PrefixLength 24 `
-DefaultGateway 10.10.10.1
```
>- DNS → ton contrôleur de domaine :
```powershell 
Set-DnsClientServerAddress `
-InterfaceAlias "Ethernet" `
-ServerAddresses ("10.10.10.10")
```
>-WSUS01
```powsershell
New-NetIPAddress `
-InterfaceAlias "Ethernet" `
-IPaddress 10.10.10.30 `
-PrefixLength 24 `
-DefaultGateway 10.10.10.1
```
>- DNS :
Set-DnsClientServerAddress `
-InterfaceAlias "Ethernet" `
-ServerAddresses ("10.10.10.10")

- Renommer les serveurs
	- Sur chaque VM :

>- FILE01
```powsershell 
Rename-Computer FILE01 -Restart
```
>- WSUS01
```powershell
Rename-Computer WSUS01 -Restart
```
- Joindre le domaine

>- Supposons ton domaine :
```powsershell
ad.corptech.com
```
>- Sur FILE01 :
```powershell 
Add-Computer `
-DomainName "ad.corptech.com" `
-Credential "CORPTECH\Administrator" `
-Restart
```
- Même chose sur WSUS01.

- Installer le rôle FILE SERVER

>- Sur FILE01 :
```powershell
Install-WindowsFeature FS-FileServer -IncludeManagementTools
```

>- Créer un dossier partagé :
```powershell
New-Item -ItemType Directory -Path "D:\Shares"
```
>- Partager :
```powershell 
New-SmbShare `
-Name "Shares" `
-Path "D:\Shares" `
-FullAccess "CORPTECH\Domain Admins"
```
- Installer WSUS

>- Sur WSUS01 :
```powershell 
Install-WindowsFeature `
-Name UpdateServices `
-IncludeManagementTools
```
>- Configurer WSUS :
```powershell
wsusutil postinstall CONTENT_DIR=D:\WSUS
```

>- Puis ouvrir :
``` Server Manager
→ Tools
→ Windows Server Update Services
```

- Infrastrusture

```
 VLAN10 (Serveurs)
10.10.10.0/24
│
├── DC01
│   10.10.10.10
│   AD DS
│   DNS
│   DHCP
│
├── FILE01
│   10.10.10.20
│   File Server
│
└── WSUS01
    10.10.10.30
    Windows Update Server
```
