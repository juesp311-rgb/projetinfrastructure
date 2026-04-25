---
# File Server
---


- Étape 1 — Installer le rôle File Server

> AD-Server

```
Install-WindowsFeature `
    -Name FS-FileServer `
    -IncludeManagementTools
```

- Étape 2 — Créer les dossiers

```
# Créer le dossier racine
New-Item -Path "C:\Partages" -ItemType Directory
```

```
# Créer les sous-dossiers
New-Item -Path "C:\Partages\Informatique" -ItemType Directory
New-Item -Path "C:\Partages\RH" -ItemType Directory
New-Item -Path "C:\Partages\Commun" -ItemType Directory
```

- Étape 3 — Créer les partages réseau

```
# Partage Informatique
New-SmbShare `
    -Name "Informatique" `
    -Path "C:\Partages\Informatique" `
    -FullAccess "MONLABO\GRP_Informatique" `
    -Description "Partage département Informatique"
```

```
# Partage RH
New-SmbShare `
    -Name "RH" `
    -Path "C:\Partages\RH" `
    -FullAccess "MONLABO\GRP_RH" `
    -Description "Partage département RH"
```

```
# Partage Commun
New-SmbShare `
    -Name "Commun" `
    -Path "C:\Partages\Commun" `
    -FullAccess "MONLABO\Domain Users" `
    -Description "Partage commun à tous"
```

- Étape 4 — Configurer les droits NTFS

```
# Droits NTFS Informatique
$acl = Get-Acl "C:\Partages\Informatique"
$acl.SetAccessRuleProtection($true, $false)

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MONLABO\GRP_Informatique",
    "Modify",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($rule)

$ruleAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MONLABO\Administrateur",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($ruleAdmin)
Set-Acl "C:\Partages\Informatique" $acl
```

```
# Droits NTFS RH
$acl = Get-Acl "C:\Partages\RH"
$acl.SetAccessRuleProtection($true, $false)

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MONLABO\GRP_RH",
    "Modify",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($rule)

$ruleAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MONLABO\Administrateur",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($ruleAdmin)
Set-Acl "C:\Partages\RH" $acl
```
```
# Droits NTFS Commun
$acl = Get-Acl "C:\Partages\Commun"
$acl.SetAccessRuleProtection($true, $false)

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MONLABO\Domain Users",
    "Modify",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($rule)

$ruleAdmin = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "MONLABO\Administrateur",
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($ruleAdmin)
Set-Acl "C:\Partages\Commun" $acl
```

- Étape 5 — Vérifier les partages

```
Get-SmbShare | Select-Object Name, Path, Description
```

> Doit afficher Informatique, RH, Commun

- Étape 6 — Vérifier l'accès depuis un client

> Sur Win10-Client1, ouvrez PowerShell en administrateur :

```
# Tester l'accès au partage
Test-Path "\\AD-Server\Informatique"
Test-Path "\\AD-Server\Commun"
```



