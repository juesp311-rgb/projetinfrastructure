---
# serveur Web + DB
---

## Architecture

```
Utilisateur (navigateur)
        ↓
Serveur Web (IIS ou Apache)  → affiche les pages
        ↓
Serveur DB (SQL Server)      → stocke les données
```

```
✅ Intranet d'entreprise
✅ Application RH (congés, fiches de paie)
✅ Ticketing interne (helpdesk)
✅ ERP / CRM
✅ Site vitrine
```

- Lien avec votre lab existant
```
✅ Les utilisateurs AD (jdupont, pdurand)
   peuvent s'authentifier sur l'intranet
   via Windows Authentication

✅ PFsense contrôle qui accède au serveur web
   depuis l'extérieur via des règles de pare-feu

✅ Les données sont stockées en DB
   et accessibles uniquement aux groupes AD autorisés
```

- Architecture cible pour votre lab

```
monlabo.local
│
├── AD-Server      192.168.56.10  → AD + DNS + DHCP + File Server
├── PFsense        192.168.56.2   → Routeur/Firewall
├── Win10-Client1  192.168.56.21  → Poste utilisateur jdupont
├── Win10-Client2  192.168.56.22  → Poste utilisateur (non configuré)
└── SRV-Web        192.168.56.20  → IIS + SQL Server  ← nouveau
```

> ✅ IIS + SQL Server Express

```
Intranet monlabo.local
    ├── Page d'accueil accessible à tous les utilisateurs AD
    ├── Section Informatique → accessible uniquement GRP_Informatique
    ├── Section RH           → accessible uniquement GRP_RH
    └── Base de données      → stocke les infos utilisateurs
```

---
## Création Vm SRV-Web
---

- Sous Linux 

```
cd ~/formationtssr/projetinfrastructure/1-virtualisation/
./1-createvm.sh "SRV-Web" "Windows2022_64" 4096 60 ~/isooperatingsystem/server2022.iso
```

- Détail des paramètres

```
"SRV-Web"           → nom de la VM
"Windows2022_64"    → OS type Windows Server 2022
4096                → 4 Go de RAM
60                  → 60 Go de disque
~/isooperatingsystem/server2022.iso → votre ISO
```

> Bureau Windows serveur 2022 eval

- Étape 1 — Renommer le serveur et configurer l'IP

```
Rename-Computer -NewName "SRV-Web" -Force
```

```
$ifIndex = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1).InterfaceIndex

New-NetIPAddress `
    -InterfaceIndex $ifIndex `
    -IPAddress "192.168.56.20" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.56.2"

Set-DnsClientServerAddress `
    -InterfaceIndex $ifIndex `
    -ServerAddresses "192.168.56.10"
```

```
Restart-Computer -Force
```

> ⚠️ On choisit 192.168.56.20 car :
>> 192.168.56.2  → PFsense
>>192.168.56.10 → AD-Server
>>192.168.56.20 → SRV-Web  ← hors plage DHCP
>>192.168.56.21 → Win10-Client1
>>192.168.56.22 → Win10-Client2


---
## Configuration VM
---

- Étape 1 — Renommer le serveur et configurer l'IP
```
Rename-Computer -NewName "SRV-Web" -Force
```

```
$ifIndex = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1).InterfaceIndex

New-NetIPAddress `
    -InterfaceIndex $ifIndex `
    -IPAddress "192.168.56.20" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.56.2"

Set-DnsClientServerAddress `
    -InterfaceIndex $ifIndex `
    -ServerAddresses "192.168.56.10"
```

```
Restart-Computer -Force
```


>⚠️ On choisit 192.168.56.20 car :
```
>>192.168.56.2  → PFsense
>>192.168.56.10 → AD-Server
>>192.168.56.20 → SRV-Web  ← hors plage DHCP
>>192.168.56.21 → Win10-Client1
>>192.168.56.22 → Win10-Client2
```


- Étape 2 — Joindre le domaine
```
# Vérifier la connectivité avec AD-Server
Test-Connection 192.168.56.10
```

```
# Synchroniser le temps
w32tm /config /manualpeerlist:"192.168.56.10" /syncfromflags:manual /update
w32tm /resync /force
```

```
# Joindre le domaine
Add-Computer `
    -DomainName "monlabo.local" `
    -Credential (Get-Credential) `
    -Restart -Force
```

> Entrez
>> Utilisateur : MONLABO\Administrateur
>> Mot de passe :


```
# Vérifiez sur AD-Server après redémarrage
Get-ADComputer -Filter * | Select-Object Name
```

> Doit afficher
>> AD-Server
>>Win10-Client1
>>Win10-Client2
>>SRV-Web


- Étape 3 — Installer IIS sur SRV-Web
```
Install-WindowsFeature `
    -Name Web-Server `
    -IncludeManagementTools `
    -IncludeAllSubFeature
```
```
# Vérifiez
Get-WindowsFeature Web-Server
```
```
## Testez IIS depuis votre Linux hôte
curl http://192.168.56.20
```



---
## Configure Firewall
---

```
# Supprimer l'ancienne règle HTTP
Remove-NetFirewallRule -DisplayName "IIS HTTP" -ErrorAction SilentlyContinue

# Recréer HTTP + HTTPS + ICMP
New-NetFirewallRule `
    -DisplayName "IIS HTTP" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Profile Any `
    -Action Allow

New-NetFirewallRule `
    -DisplayName "IIS HTTPS" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 443 `
    -Profile Any `
    -Action Allow

New-NetFirewallRule `
    -DisplayName "ICMP Allow" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -Profile Any `
    -Action Allow

```
```
## Test depuis Linux
curl http://192.168.56.20
```


---
##  Installer SQL Server Express
---

- 1. Téléchargez SQL Server Express
```
# Télécharger l'installateur
Invoke-WebRequest `
    -Uri "https://go.microsoft.com/fwlink/p/?linkid=2216019&clcid=0x40c&culture=fr-fr&country=fr" `
    -OutFile "C:\SQLServerExpress.exe"
```
```
## Vérifier le nom de fichier
Get-ChildItem "C:\SQLMedia"
```

- 2. Lancez le téléchargement du package complet

```
C:\SQLExpress.exe /QUIET /ACTION=Download /MEDIAPATH=C:\SQLMedia /MEDIATYPE=Core
```

- Méthode installation avec Process 
```
Start-Process -FilePath "C:\SQLMedia\SQLEXPR_x64_FRA.exe" `
    -ArgumentList "/ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='MONLABO\Administrateur' /AGTSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /IACCEPTSQLSERVERLICENSETERMS /INDICATEPROGRESS" `
    -Wait `
    -NoNewWindow
```
