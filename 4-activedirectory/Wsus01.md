# WSUS01

```powershell
# Installer WSUS
Install-WindowsFeature -Name UpdateServices, UpdateServices-RSAT, UpdateServices-UI -IncludeManagementTools

# Créer le dossier pour les mises à jour
New-Item -Path "D:\WSUS" -ItemType Directory

# Post-installation
& "C:\Program Files\Update Services\Tools\wsusutil.exe" postinstall CONTENT_DIR=D:\WSUS

# Vérifier que le service WSUS fonctionne
Get-Service -Name WSUSService
Start-Service -Name WSUSService

# Ouvrir la console graphique (optionnel)
Start-Process "wsus.msc"


#---
# Synchronisation initiale via PowerShell
#--- 

# Charger l’assembly WSUS
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null

# Récupérer le serveur WSUS local
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()

# Créer un objet de synchronisation
$syncManager = $wsus.GetSubscription()

# Lancer la synchronisation
$syncManager.StartSynchronization()


#---
# Crée le groupe Clients
#---

```powershell
# Récupérer le groupe “Clients” s’il existe
$group = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq "Clients" }

# Si le groupe n’existe pas, le créer
if (-not ($wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq "Clients" })) { $wsus.CreateComputerTargetGroup("Clients") }
```



#---
# Approuver les mises à jour sur FILE01
#---


- 🧭 1️⃣ Se connecter à WSUS (FILE01)
```powershell
Import-Module UpdateServices
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")

$wsus = Get-WsusServer -Name "localhost" -PortNumber 8530
```


- 🧭 2️⃣ Récupérer les mises à jour disponibles
```powershell
$updates = $wsus.GetUpdates() | Where-Object { $_.IsDeclined -eq $false }
```

- 🧭 3️⃣ Récupérer le groupe d’ordinateurs
-> WSUS utilise des groupes, généralement “All Computers” par défaut :

```powershell
$group = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq "All Computers" }
```

- 🧭 4️⃣ Approuver les mises à jour
```powershell
foreach ($update in $updates) {
    $update.Approve("Install", $group)
}
```

- 🧪 5️⃣ Vérifier qu’il y a des mises à jour approuvées
```powershell
$updates | Select-Object Title, IsApproved | Format-Table -AutoSize
```


#---
# 🧭 6️⃣ Retour sur CLIENT01
#---

```powsershell
UsoClient.exe StartScan
UsoClient.exe StartDownload
UsoClient.exe StartInstall
```


#---
# 🧠 Bonnes pratiques (important)
#---

- 👉 Évite d’approuver TOUTES les mises à jour en prod
- 👉 Mieux vaut filtrer (ex : sécurité uniquement)


```powsershell
$updates = $wsus.GetUpdates() | Where-Object { $_.Title -like "*Security*" }
```

#---
# Vérifier les updates
#---

- Sur CLIENT01
```powershell
Get-HotFix
```

-> Version plus lisible
```powershell
Get-HotFix | Select-Object HotFixID, InstalledOn | Sort-Object InstalledOn -Descending
```

- 🧭 3️⃣ Voir via Windows Update (ligne de commande)
```powershell
wmic qfe list brief /format:table
```

- 🧭 4️⃣ Vérifier que WSUS est bien utilisé
```powershell
Get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate"
```
-> WUServer : http://FILE01:8530


- 🧭 5️⃣ Vérifier les mises à jour en attente
```powershell
UsoClient.exe StartScan
```
-> Puis
```powershell
Get-WindowsUpdateLog
```


#---
# Voir les mises à jour non installées sur CLIENT01
#---

## 1️⃣ Méthode moderne (recommandée)

- Sur CLIENT01 
```powsershell
UsoClient.exe StartScan
```

- Ensuite, générer le log :
```powershell
Get-WindowsUpdateLog
```

- 👉 Dans le fichier généré, cherche :

	- Updates found

	- Download

	- Install	

- 💡 C’est technique mais très utile pour debug.



## 🧭 2️⃣ Méthode propre avec module (meilleure 👇)

- Install-Module PSWindowsUpdate -Force
```powsershell
Install-Module PSWindowsUpdate -Force
```

- Puis

```powershell
Import-Module PSWindowsUpdate

Get-WindowsUpdate
```


## 🧭 3️⃣ Voir uniquement les updates WSUS

```powershell
Get-WindowsUpdate -MicrosoftUpdate:$false
```

## 🧭 5️⃣ Vérification rapide WSUS actif

```powershell
Get-WUSettings









