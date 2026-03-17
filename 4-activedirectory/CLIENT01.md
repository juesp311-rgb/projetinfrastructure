# CLIENT01

## Prérequis

- Sur Vbox : réseau interne : VLAN10


- Renomme l'ordinateur
```powershell 
Rename-Computer -NewName "CLIENT01" -Restart
```

- Rename interface/RemoveIP/New-IPAdress
```powershell
```

- Configure le DNS vers IP Windows Server
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.1
```
- Connaître le nom de domaine du contrôleur de domaine Windows serveur
```powershell
(Get-ADDomain).DNSRoot
```
-> lab.local 

- Connaître le Compte utilisateur :
-> lab\Administrateur

## Ajout de CLIENT01 au domain lab.local (Windows Server)
```powershell
Add-Computer -DomainName "lab.local" -Credential lab\Administrateur -Restart
```

- Vérifier : 
```powershell
(Get-WmiObject Win32_ComputerSystem).Domain
```
->lab.local


## Configuration WSUS

### 1️⃣ Pré-requis

- CLIENT01 et FILE01 doivent pouvoir communiquer sur le réseau.
```ping FILE01```


- Vérifie que le port 8530 (HTTP) ou 8531 (HTTPS) est ouvert depuis CLIENT01 vers FILE01.

```powershell
# Vérifier le port 8530
Test-NetConnection -ComputerName FILE01 -Port 8530
->TcpTestSucceeded : true

# Vérifier le port 8531
Test-NetConnection -ComputerName FILE01 -Port 8531
->TcpTestSucceeded : True

```
- WSUS est installé et fonctionne sur FILE01.


### 1️⃣ Définir le serveur WSUS et activer les mises à jour automatiques

```
# Définir le serveur WSUS
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUServer" -Value "http://FILE01:8530"
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "WUStatusServer" -Value "http://FILE01:8530"

# Activer l’utilisation du serveur WSUS
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1

# Configurer les mises à jour automatiques : Auto download and schedule install
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 4

# (Optionnel) Empêcher le redémarrage automatique si un utilisateur est connecté
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1

```


### 2️⃣ Forcer la détection des mises à jour
```powsershell
# Détecter les mises à jour
UsoClient.exe StartScan

# Télécharger les mises à jour disponibles
UsoClient.exe StartDownload

# Installer les mises à jour
UsoClient.exe StartInstall
```


### 3️⃣ Vérifier la connexion à WSUS

- Pour confirmer que CLIENT01 est bien enregistré sur FILE01 :

	- Ouvre la console WSUS sur FILE01 (wsus.msc)

	- Va dans Computers → All Computers

	- ### 1️ Définir le serveur WSUS et activer les mises à jour automatiques

```

