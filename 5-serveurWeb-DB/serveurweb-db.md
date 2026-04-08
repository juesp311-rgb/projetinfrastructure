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
>Failed 

> Installation en mode graphique OK/

---
## Tester l'installation
---

- Vérifiez que le service tourne
```
Get-Service | Where-Object Name -like "*SQL*"
```

- Activez SQL Server au démarrage automatique
```
Set-Service -Name "MSSQL`$SQLEXPRESS" -StartupType Automatic
```

- Ouvrez le port SQL Server dans le pare-feu
```
New-NetFirewallRule `
    -DisplayName "SQL Server Express" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 1433 `
    -Profile Any `
    -Action Allow
```

- Testez la connexion SQL depuis SRV-Web
```
sqlcmd -S localhost\SQLEXPRESS -Q "SELECT @@VERSION"
```

- État complet de SRV-Web ✅
```
SRV-Web : 192.168.56.20
    ├── IIS      → port 80/443  ✅
    └── SQL Server 2022 Express → port 1433 ✅
```



---
## Configure la base de donnée
---

- Créer la base de données

```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "CREATE DATABASE IntranetDB"
```

```
# Vérifier la création
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "SELECT name FROM sys.databases"
```

> Doit afficher IntranetDB dans la liste


- Créez les tables de la base de données
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "USE IntranetDB; CREATE TABLE Employes (ID INT PRIMARY KEY IDENTITY, Nom NVARCHAR(50), Prenom NVARCHAR(50), Departement NVARCHAR(50), Email NVARCHAR(100), DateCreation DATETIME DEFAULT GETDATE())"
```

```
# Insérer les utilisateurs AD existants
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "USE IntranetDB; INSERT INTO Employes (Nom, Prenom, Departement, Email) VALUES ('Dupont', 'Jean', 'Informatique', 'jdupont@monlabo.local'), ('Martin', 'Marie', 'Informatique', 'mmartin@monlabo.local'), ('Durand', 'Pierre', 'RH', 'pdurand@monlabo.local')"
```

```
# Vérifier les données
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "USE IntranetDB; SELECT * FROM Employes"
```

> ✅ Table Employes créée
>>✅ 3 employés insérés :
>>   - Jean Dupont    → Informatique
>>   - Marie Martin   → Informatique
>>   - Pierre Durand  → RH

- Créer la page Intranet IIS
> Sur SRV-Web :
```
# Créer le dossier de l'intranet
New-Item -Path "C:\inetpub\wwwroot\intranet" -ItemType Directory -Force
```

``` # Créer la page HTML
$html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Intranet monlabo.local</title>
    <style>
        body { font-family: Arial; margin: 40px; background: #f0f0f0; }
        h1 { color: #003366; }
        table { border-collapse: collapse; width: 100%; background: white; }
        th { background: #003366; color: white; padding: 10px; }
        td { padding: 10px; border: 1px solid #ddd; }
        tr:nth-child(even) { background: #f9f9f9; }
    </style>
</head>
<body>
    <h1>🏢 Intranet monlabo.local</h1>
    <h2>Annuaire des employés</h2>
    <table>
        <tr>
            <th>ID</th>
            <th>Nom</th>
            <th>Prénom</th>
            <th>Département</th>
            <th>Email</th>
        </tr>
        <tr><td>1</td><td>Dupont</td><td>Jean</td><td>Informatique</td><td>jdupont@monlabo.local</td></tr>
        <tr><td>2</td><td>Martin</td><td>Marie</td><td>Informatique</td><td>mmartin@monlabo.local</td></tr>
        <tr><td>3</td><td>Durand</td><td>Pierre</td><td>RH</td><td>pdurand@monlabo.local</td></tr>
    </table>
    <br>
    <p>Serveur : SRV-Web | Domaine : monlabo.local</p>
</body>
</html>
"@
$html | Out-File "C:\inetpub\wwwroot\intranet\index.html" -Encoding UTF8
```

- Testez depuis Linux hôte
```
curl http://192.168.56.20/intranet/
```


---
## Configurer DNS intranet.monlabo.local
---

> Sur AD-Server via SSH :

- 1. Créer l'enregistrement DNS
```
Add-DnsServerResourceRecordA `
    -Name "intranet" `
    -ZoneName "monlabo.local" `
    -IPv4Address "192.168.56.20" `
    -TimeToLive 01:00:00
```

- 2. Vérifiez
```
Get-DnsServerResourceRecord `
    -ZoneName "monlabo.local" `
    -Name "intranet"
```
> Doit afficher intranet → 192.168.56.20


- 3. Testez la résolution depuis Kali
```
nslookup intranet.monlabo.local 192.168.56.10
```

- 4. Testez depuis Win10-Client1
```
Resolve-DnsName "intranet.monlabo.local"
```
> Doit afficher 192.168.56.20


- 5. Accédez via le navigateur sur Win10-Client1
```
http://intranet.monlabo.local
```
