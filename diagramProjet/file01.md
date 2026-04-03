# Creation d'un serveur de fichier
---

- Pré-requis 
	- Création d'un disque virtuel sur VBox
	- Ajout de la machine au domaine




-  Créer le dossier pour les partages

```powershell

# 1️⃣ Créer le dossier
New-Item -Path "D:\Shares\Documents" -ItemType Directory -Force

```

- 2️⃣ Configurer les permissions NTFS
```
icacls "D:\Shares" /inheritance:r
icacls "D:\Shares" /grant "lab\Administrateur:(OI)(CI)F"
icacls "D:\Shares" /grant "lab\Domain Users:(OI)(CI)M"
```



- Partager le dossier pour les administrateurs du domaine :

```powershell
New-SmbShare -Name "Shares" -Path "D:\Shares" -FullAccess "lab\Administrateur"
```
ou 

``` New-SmbShare -Name "Shares" -Path "D:\Shares" -FullAccess "lab\Administrateur" -ChangeAccess "lab\Domain Users"
```

- Vérifier que le partage est actif :

```powershell
Get-SmbShare | Where-Object Name -eq "Shares"
```

- Vérifier les permissions NTFS :

```powershell
Get-Acl "D:\Shares" | Format-List
```

- Vérifier les droits du partage
```
Get-SmbShareAccess -Name "Shares"
```



>💡 Prochaine étape typique dans un lab Active Directory :
>
>>1️⃣ créer des groupes AD
>
>>2️⃣ créer des dossiers par service (IT, RH, Finance)
>
>>3️⃣ appliquer les permissions NTFS
-  Créer le dossier pour les partages

```powershell
