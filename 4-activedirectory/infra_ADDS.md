# Active Directory Home Lab (System Admnistration)
## Configuration Active Directory

- VM1 Windows Server 2022  Serveur AD

	- Interfaces réseau :

		- VLAN20-USER → 10.10.20.1 (serveur DNS + passerelle pour VLAN20)

		- VLAN30-MONITORING → 10.10.30.1

		- NAT / SSH → accès Internet / administration

	- Rôles installés : ADDS + DNS

- VM Windows 10 CLIENT01 et CLIENT02

	- Carte réseau connectée à VLAN20-USER

	- IP statique ou DHCP dans le sous-réseau 10.10.20.0/24

	- DNS → 10.10.20.1 (IP du serveur AD)

- Communication :

	- CLIENT01 / CLIENT02 → ping 10.10.20.1 ✅

	- Serveur AD → ping VLAN20 clients ✅

	- Serveur AD:  le routage VLAN30-MONITORING

## Etapes Virtualbox
- VM Windows 10 :

	- Réseau → Activer un adaptateur

	- Attacher à → Internal Network ou Réseau interne (nom = VLAN20-USER)

	- Cette interface va se “connecter” uniquement à la VM1 (Windows Server) sur le même VLAN.

- Configurer l’IP sur la VM :


Réponse positive → VM peut joindre le serveur AD et sera prête à joindre le domaine.

## Etapes 

-  → VM1  Windows Server 2022, contrôleur de domaine + DNS + passerelle VLAN20


- Configurer VM2 dans VirtualBox

	- Activer deux cartes réseau internes :

		- Adaptateur 1 → VLAN20-USER (simule CLIENT01)

		- Adaptateur 2 → VLAN20-USER (simule CLIENT02)

- Attribuer une IP statique à chaque interface

	- Interface CLIENT01 :

		- IP : 10.10.20.10

		- Masque : 255.255.255.0

		- Passerelle : 10.10.20.1 (serveur AD)

		- DNS : 10.10.20.1	

	- Interface CLIENT02 :

		- IP : 10.10.20.11

		- Masque : 255.255.255.0

		- Passerelle : 10.10.20.1

		- DNS : 10.10.20.1

Vérifier la connectivité
Depuis VM2 (pour chaque interface) :


## Commandes installation AD DS

###  VM1 Windows Server 2022
- Install ADDS
```bash 
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
```

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
	- Résultat attendu :
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
} else {
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





