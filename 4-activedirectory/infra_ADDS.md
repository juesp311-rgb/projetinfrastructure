# Active Directory Home Lab (System Admnistration)

## Commandes installation AD DS

###  VM1 Windows Server 2022
- Install ADDS
```bash 
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```
et 
``` Install DNS ...```


- Crée la forêt et le domaine
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
> Résultat attendu :
> dc01.ad.corptech.com   10.10.10.10

- Créer les ordinateurs dans AD (sur VM1)
```powershell 
New-ADComputer -Name "CLIENT01" -SamAccountName "CLIENT01" -Path "CN=Computers,DC=corptech,DC=local" -Enabled $true
New-ADComputer -Name "CLIENT02" -SamAccountName "CLIENT02" -Path "CN=Computers,DC=corptech,DC=local" -Enabled $true
```

- Vérifier que les ordinateurs existent dans AD

```powershell
Get-ADComputer -Filter * | Select Name
```

>Tu devrais voir :
>
>Name
>
>----
>
>CLIENT01
>
>CLIENT02
>
>WIN-2FVON6A0R35   (ton contrôleur de domaine)


- Tester la communication avec le serveur AD

```powershell
ping 10.10.20.1
```
```powershell
nslookup corptech.local
```
-> failed

- Joindre la machine au domaine 
	- Sur CLIENT01 :
```powershell
Add-Computer -DomainName corptech.local -Credential corptech.local\Administrateur -Restart
```
Configure et vérifie le DNS
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.20.1
```

- Tester directement ton DNS Active Directory
```powershell
nslookup corptech.local 10.10.20.1
```
 ⭐




# Installer les outils AD
---

```
Install-WindowsFeature RSAT-AD-PowerShell

```























# -------------------------------
# Script PowerShell pour AD
# Domaine : ad.corptech.com
# -------------------------------

Import-Module ActiveDirectory

# Variables
$DomainPath = "DC=ad,DC=corptech,DC=com"

# 1️⃣ Créer les OU
$ouUsers = "OU=Utilisateurs,$DomainPath"
$ouGroups = "OU=Groupes,$DomainPath"

# Création des OU si elles n'existent pas déjà
if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Utilisateurs'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Utilisateurs" -Path $DomainPath
    Write-Host "OU 'Utilisateurs' créée."
1️⃣ Vérifier si le module est disponible

Get-Module -ListAvailable

    Tu devrais voir un module appelé ActiveDirectory

    Si tu ne le vois pas, il faut installer le rôle RSAT ou ADDS Tools.

2️⃣ Installer le module (si nécessaire)

Sur Windows Server 2022 (ta VM DC) :

# Installer les outils AD
Install-WindowsFeature RSAT-AD-PowerShell

    Après l’installation, tu peux vérifier :

Import-Module ActiveDirectory

    Ensuite la commande fonctionne :

Get-ADComputer -Filter * | Select-Object Name} else {
    Write-Host "OU 'Utilisateurs' existe déjà."
}

if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Groupes'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Groupes" -Path $DomainPath
    Write-Host "OU 'Groupes' créée."
} else {
    Write-Host "OU 'Groupes' existe déjà."
}

# 2️⃣ Créer des utilisateurs d'exemple
$users = @(
    @{Name="Jean Dupont"; Sam="jdupont"; Email="jdupont@ad.corptech.com"},
    @{Name="Marie Martin"; Sam="mmartin"; Email="mmartin@ad.corptech.com"},
    @{Name="Alice Leroy"; Sam="aleroy"; Email="aleroy@ad.corptech.com"}
)

foreach ($user in $users) {
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.Sam)'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name $user.Name `
            -SamAccountName $user.Sam `
            -UserPrincipalName $user.Email `
            -Path $ouUsers `
            -AccountPassword (ConvertTo-SecureString "MotDePasseComplexe123!" -AsPlainText -Force) `
            -Enabled $true
        Write-Host "Utilisateur '$($user.Name)' créé."
    } else {
        Write-Host "Utilisateur '$($user.Name)' existe déjà."
    }
}

# 3️⃣ Créer des groupes
$groups = @("IT_Admins", "Ventes", "Support")

foreach ($group in $groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $group `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $ouGroups
        Write-Host "Groupe '$group' créé."
    } else {
        Write-Host "Groupe '$group' existe déjà."
    }
}

# 4️⃣ Ajouter des utilisateurs aux groupes
Add-ADGroupMember -Identity "IT_Admins" -Members "jdupont"
Add-ADGroupMember -Identity "Ventes" -Members "mmartin"
Add-ADGroupMember -Identity "Support" -Members "aleroy"

Write-Host "Tous les utilisateurs ont été ajoutés aux groupes correspondants."
```


```





