# Creation d'un serveur de fichier

#---
# Joindre la VM au domaine lab.local
#---
```powershell
Add-Computer -DomainName "lab.local" -Credential (Get-Credential) -Restart
```

#---
# Création sur VBOX d'un disque virtuel sur FILE01
#---

#---
# Initialisez le disque et créez une partition D: :
```powershell

# Récupérer le disque non initialisé
$disk = Get-Disk | Where-Object PartitionStyle -eq 'RAW'

# Initialiser le disque
Initialize-Disk -Number $disk.Number -PartitionStyle MBR

# Créer une partition unique et formater en NTFS
New-Partition -DiskNumber $disk.Number -UseMaximumSize -DriveLetter D | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

# Vérifier que D: existe
Test-Path D:\```

```

#---
# Créer le dossier pour les partages
#---

```powershell
# Crée le dossier Shares et un sous-dossier Documents
New-Item -Path "D:\Shares\Documents" -ItemType Directory -Force
```

#---
# Configurer le partage SMB pour le domaine AD
#---

- Partager le dossier pour les administrateurs du domaine :
```powershell
New-SmbShare -Name "Shares" -Path "D:\Shares" -FullAccess "lab\Administrateur"

- Vérifier que le partage est actif :
```powershell
Get-SmbShare | Where-Object Name -eq "Shares"
```
- Vérifier les permissions NTFS :
```powershell
Get-Acl "D:\Shares" | Format-List
```
#---
# Tester le partage depuis l'explorateur
#---
\\10.10.10.20créer des groupes AD
2️⃣ créer des dossiers par service (IT, RH, Finance)
3️⃣ appliquer les permissions NTFS
4️⃣ monter automatiquement les lecteurs réseau avec GPO\Shares



```
💡 Prochaine étape typique dans un lab Active Directory :

1️⃣ créer des groupes AD
2️⃣ créer des dossiers par service (IT, RH, Finance)
3️⃣ appliquer les permissions NTFS
4️⃣ monter automatiquement les lecteurs réseau avec GPO
```
