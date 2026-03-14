# WindowsServer2022
## Vbox
⚠️ La VM doit être éteinte.

Vérifier les interfaces reseaux

```bash
Get-NetAdpater
```
>- Interface NAT = 10.0.2.2

- Crée 3  interface réseau interne "intnet"
	- VLAN 10
```bash 
VBoxManage modifyvm "WindowsServer2022" \
--nic2 intnet \
--intnet2 "VLAN10"
```
	- VLAN20
```bash
VBoxManage modifyvm "WindowsServer2022" \
--nic3 intnet \
--intnet3 "VLAN20"
```
	- VLAN30
```bash
VBoxManage modifyvm "WindowsServer2022" \
--nic4 intnet \
--intnet4 "VLAN30"
```

- Vérifier la configuration réseau
```bash
VBoxManage showvminfo "WindowsServer2022" | grep -i NIC
```


#---
# Installer OpenSSH Server
#---

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```
#---
#Démarrer le servcice SSH
#---
```powershell
Start-Service sshd
```
#---
#Activer le démarrage automatique
#---
```powershell
Set-Service -Name sshd -StartupType Automatic
```


#---
# Vérifier que le service fonctionne
#---
```powershell
Get-Service sshd
```

#---
# Autoriser SSH dans le firewall
#---
- Vérifier
```powershell
Get-NetFirewallRule -Name *ssh*
```
- Sinon
```powershell
New-NetFirewallRule -Name sshd `
-DisplayName "OpenSSH Server" `
-Enabled True `
-Direction Inbound `
-Protocol TCP `
-Action Allow `
-LocalPort 22
```

#---
#Tester la connexion SSH
#---

```powershell
ssh Administrateur@10.10.30.10
```
#---
# Vérifier que le port SSH écoute
#---
```powershell
netstat -an | findstr :22
```



# ---------------------------
# 1️⃣ Renommer les interfaces
# ---------------------------
Rename-NetAdapter -Name "Ethernet" -NewName "NAT"
Rename-NetAdapter -Name "Ethernet 2" -NewName "VLAN10-SERVERS"
Rename-NetAdapter -Name "Ethernet 3" -NewName "VLAN20-USERS"
Rename-NetAdapter -Name "Ethernet 4" -NewName "VLAN30-MGMT"


#---
# Supprimer les anciennes addresse APIPA
#---
```powershell
Remove-NetIPAddress -InterfaceAlias "VLAN10" -Confirm:$false
Remove-NetIPAddress -InterfaceAlias "VLAN20" -Confirm:$false
```

# ---------------------------
# 3️⃣ Configurer les VLAN internes avec IP statiques
# ---------------------------


-  VLAN10 SERVERS
```powershell
New-NetIPAddress -InterfaceAlias "VLAN10-SERVERS" -IPAddress 10.10.10.1 -PrefixLength 24
```
 
- VLAN20 USERS
```powershell
New-NetIPAddress -InterfaceAlias "VLAN20-USERS" -IPAddress 10.10.20.1 -PrefixLength 24
```

# VLAN30 MANAGEMENT
New-NetIPAddress -InterfaceAlias "VLAN30-MGMT" -IPAddress 10.10.30.1 -PrefixLength 24







# ---------------------------
# 4️⃣ Configurer NAT pour Internet via DHCP VirtualBox
# ---------------------------
Set-NetIPInterface -InterfaceAlias "NAT" -Dhcp Enabled
# Remettre DNS VirtualBox pour NAT
Set-DnsClientServerAddress -InterfaceAlias "NAT" -ServerAddresses 10.0.2.3

# ---------------------------
# 5️⃣ Vérification
# ---------------------------
Write-Host "`n=== Résultat IP ===`n"
Get-NetIPAddress | Sort-Object InterfaceAlias | Format-Table InterfaceAlias,IPAddress,PrefixLength,DefaultGateway

Write-Host "`n=== Test ping ===`n"
ping 8.8.8.8
ping google.com


#---
#Installer les rôles ADDS et DNS
---
```powershell 
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-WindowsFeature DNS -IncludeManagementTools
```

-> Vérifier
```powershell
Get-WindowsFeature AD-Domain-Services,DNS
```

#---
# Promouvoir le serveur en contrôleur de domaine
#---

- Après installation
```powershell
Import-Module ADDSDeployment
```

- Puis créer un nouveau domaine dans une nouvelle forêt :

```powershell

Install-ADDSForest `
-DomainName "lab.local" `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-InstallDns:$true `
-Force:$true
```

#---
# Vérifier le rôle AD et DNS
#---

```powershell
Get-Service -Name NTDS, DNS
```

- Tester le DNS
```powershell
nslookup lab.local
```




- Résultat
	- DC01
	- DNS
	- Active Directory
	- corptech.local
