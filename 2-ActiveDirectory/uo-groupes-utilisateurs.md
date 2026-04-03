# Création des UO, Groupes et Utilisateurs

- Architerture du lab
	- AD-Server : Schéma complet de votre lab.


```
monlabo.local
│
├── UO : Informatique
│     ├── Groupe : GRP_Informatique
│     ├── Utilisateur : jdupont
│     └── Utilisateur : mmartin
│
├── UO : RH
│     ├── Groupe : GRP_RH
│     └── Utilisateur : pdurand
│
└── UO : Ordinateurs
      ├── Win10-Client1
      └── Win10-Client2

```

	- Exemple concret 

```
Groupe : GRP_Informatique
    ├── jdupont (Jean Dupont)
    ├── mmartin (Marie Martin)
    └── → accès au dossier partagé \\AD-Server\Informatique

```

- Étape 1 — Créer les Unités d'Organisation

```
# UO Informatique
New-ADOrganizationalUnit `
    -Name "Informatique" `
    -Path "DC=monlabo,DC=local" `
    -ProtectedFromAccidentalDeletion $true
```

```
# UO RH
New-ADOrganizationalUnit `
    -Name "RH" `
    -Path "DC=monlabo,DC=local" `
    -ProtectedFromAccidentalDeletion $true
```

```
# UO Ordinateurs
New-ADOrganizationalUnit `
    -Name "Ordinateurs" `
    -Path "DC=monlabo,DC=local" `
    -ProtectedFromAccidentalDeletion $true
```

- Étape 2 — Vérifier les UO créées

```
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
```
> Doit afficher Informatique, RH, Ordinateurs

- Étape 3 — Créer les Groupes

```
# Groupe Informatique
New-ADGroup `
    -Name "GRP_Informatique" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Informatique,DC=monlabo,DC=local" `
    -Description "Groupe du département Informatique"
```

```
# Groupe RH
New-ADGroup `
    -Name "GRP_RH" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=RH,DC=monlabo,DC=local" `
    -Description "Groupe du département RH"

```

- Étape 4 — Vérifier les groupes créés

```
Get-ADGroup -Filter * | Select-Object Name, GroupScope, GroupCategory

```
> Doit afficher GRP_Informatique et GRP_RH


- Étape 5 — Créer les Utilisateurs

```

# Jean Dupont - Informatique
New-ADUser `
    -Name "Jean Dupont" `
    -GivenName "Jean" `
    -Surname "Dupont" `
    -SamAccountName "jdupont" `
    -UserPrincipalName "jdupont@monlabo.local" `
    -Path "OU=Informatique,DC=monlabo,DC=local" `
    -AccountPassword (ConvertTo-SecureString "Azerty123!" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -ChangePasswordAtLogon $true

```

```
# Marie Martin - Informatique
New-ADUser `
    -Name "Marie Martin" `
    -GivenName "Marie" `
    -Surname "Martin" `
    -SamAccountName "mmartin" `
    -UserPrincipalName "mmartin@monlabo.local" `
    -Path "OU=Informatique,DC=monlabo,DC=local" `
    -AccountPassword (ConvertTo-SecureString "Azerty123!" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -ChangePasswordAtLogon $true

```

```
# Pierre Durand - RH
New-ADUser `
    -Name "Pierre Durand" `
    -GivenName "Pierre" `
    -Surname "Durand" `
    -SamAccountName "pdurand" `
    -UserPrincipalName "pdurand@monlabo.local" `
    -Path "OU=RH,DC=monlabo,DC=local" `
    -AccountPassword (ConvertTo-SecureString "Azerty123!" -AsPlainText -Force) `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -ChangePasswordAtLogon $true

```

- Étape 6 — Ajouter les utilisateurs dans leurs groupes

```

# Jean Dupont et Marie Martin → GRP_Informatique
Add-ADGroupMember `
    -Identity "GRP_Informatique" `
    -Members "jdupont", "mmartin"
```

```
# Pierre Durand → GRP_RH
Add-ADGroupMember `
    -Identity "GRP_RH" `
    -Members "pdurand"

```


- Étape 7 — Déplacer les ordinateurs dans l'UO Ordinateurs

```

# Win10-Client1
Get-ADComputer "Win10-Client1" | Move-ADObject `
    -TargetPath "OU=Ordinateurs,DC=monlabo,DC=local"

```

```
# Win10-Client1
Get-ADComputer "Win10-Client1" | Move-ADObject `
    -TargetPath "OU=Ordinateurs,DC=monlabo,DC=local"

```

- Étape 8 — Vérification globale

```
# Vérifier les utilisateurs
Get-ADUser -Filter * | Select-Object Name, SamAccountName, Enabled
```

```
# Vérifier les membres des groupes
Get-ADGroupMember "GRP_Informatique" | Select-Object Name
Get-ADGroupMember "GRP_RH" | Select-Object Name
```

```
# Vérifier les ordinateurs
Get-ADComputer -Filter * | Select-Object Name, DistinguishedName

```

>⚠️ Pièges à éviter
>
>> - ChangePasswordAtLogon $true → l'utilisateur devra changer son mot de passe à la première connexion, bonne pratique de sécurité
>> - ProtectedFromAccidentalDeletion $true → protège les UO d'une suppression accidentelle
>> - Le mot de passe doit respecter la politique de complexité de Windows Server (majuscule + chiffre + caractère spécial)



```
# Sur votre Linux hôte
VBoxManage snapshot "AD-Server"     take "AD-config-complete" --description "AD DS + DHCP + Users + Groups + OU"
VBoxManage snapshot "Win10-Client1" take "joined-domain" --description "Membre du domaine monlabo.local"
VBoxManage snapshot "Win10-Client2" take "joined-domain" --description "Membre du domaine monlabo.local"
```




