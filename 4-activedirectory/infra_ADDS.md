# Active Directory Home Lab (System Admnistration)

## Commandes installation AD DS

###  VM1 Windows Server 2022
- Installer les roles ADDS et DNS

```bash 
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Install-WindowsFeature DNS -IncludeManagementTools
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
-Force

```


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


- Joindre une  machine au domaine
        - Sur CLIENT01 :
```powershell
Add-Computer -DomainName corptech.local -Credential corptech.local\Administrateur -Restart
```

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
>CLIENT01
>CLIENT02
>WIN-2FVON6A0R35   (ton contrôleur de domaine)


- Tester la communication avec le serveur AD

```powershell
ping 10.10.20.1
```
```powershell
nslookup corptech.local
```


- Configure et vérifie le DNS

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


# 1️⃣ Créer les OU


# 2️⃣ Créer des utilisateurs d'exemple

# 3️⃣ Créer des groupes

# 4️⃣ Ajouter des utilisateurs aux groupes




