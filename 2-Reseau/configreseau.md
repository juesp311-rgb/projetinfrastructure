*# WindowsServer2022
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


#---
#DCO1
#---

```powershell
Remove-NetIPAddress -InterfaceAlias "VLAN10" -Confirm:$false
```
```powershell
Rename-NetAdapter -Name "Ethernet 2" -NewName "DC01"
```


#---
#1️⃣ Vérifier l’interface réseau et le serveur DNS
#---

```powershell
# Vérifier quelles adresses DNS sont configurées
Get-DnsClientServerAddress -InterfaceAlias "DC01"

# Vérifier la configuration IP
Get-NetIPConfiguration -InterfaceAlias "DC01"
```

#---
#2️⃣ Configurer DNS pour pointer sur GEN8 (10.10.10.1)
#---

```powershell
# Définir le DNS principal sur GEN8
Set-DnsClientServerAddress -InterfaceAlias "DC01" -ServerAddresses 10.10.10.1
```


#---
# Tester la connectivité réseau avec GEN8 (sur windows Server)
#---

```powershell 
# Ping du serveur principal
ping 10.10.10.1

# Test résolution DNS de lab.local via GEN8
nslookup lab.local 10.10.10.1

# Test des enregistrements SRV nécessaires pour AD
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.local 10.10.10.1
```

#---
# 4️⃣ Vérifier la découverte du contrôleur de domaine
#---

```powershell
# Découvrir tous les DC du domaine
Get-ADDomainController -Discover -DomainName lab.local | Format-List Name,IPv4Address,Site
```
-> ⚠ Ici, IPv4Address doit afficher 10.10.10.1 pour GEN8. Si vide, la découverte échoue encore.


#---
# 5️⃣ Vérifier la réplication AD (une fois que la découverte fonctionne)
#---

```powershell
# Voir les partenaires de réplication pour DC01
Get-ADReplicationPartnerMetadata -Target DC01 | Format-Table Server,LastReplicationSuccess,LastReplicationAttempt
```

#---
# 6️⃣ Test final DNS et AD
#---

```powershell 
# Vérifier que DC01 peut résoudre son domaine et les SRV
nslookup lab.local
nslookup _ldap._tcp.dc._msdcs.lab.local

# Vérifier les infos du domaine
Get-ADDomain
Get-ADForest
```

```
              lab.local

         ┌─────────────────┐
         │      GEN8       │
         │  DC1 + DNS      │
         │ 10.10.10.1      │
         └────────┬────────┘
                  │
           Réplication AD
                  │
         ┌────────┴────────┐
         │      DC01        │
         │  DC2 + DNS      │
         │ 10.10.10.10     │
         └─────────────────┘
```












