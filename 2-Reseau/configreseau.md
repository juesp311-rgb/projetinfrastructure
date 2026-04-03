# Configuration PowerShell AD DS — Windows Server 2022

## Configure Windows Server 2022
---



### Étape 1 — IP fixe + renommage

- 1. Vérifier le nom de l'interface réseau
``` Get-NetAdapter ```



-  2. Configurer l'IP fixe sur l'interface Host-Only

```

New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress "192.168.56.10" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.56.1"

```

- 3. Configurer le DNS

```

Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet" `
    -ServerAddresses "127.0.0.1"

```

- 4. Renommer le serveur

```

Rename-Computer -NewName "AD-Server" -Force

```

5. Redémarrer

```
Restart-Computer -Force

```

### Étape 2 — Installation du rôle AD DS



- 1. Installer le rôle AD DS

```

Install-WindowsFeature `
    -Name AD-Domain-Services `
    -IncludeManagementTools

```

- 2. Vérifier l'installation

```

Get-WindowsFeature AD-Domain-Services
```

### Étape 3 — Promotion en contrôleur de domaine

- 1. Importer le module AD DS

```

Import-Module ADDSDeployment

```

- 2. Promouvoir le serveur en DC

```

Install-ADDSForest `
    -DomainName "monlabo.local" `
    -DomainNetbiosName "MONLABO" `
    -ForestMode "WinThreshold" `
    -DomainMode "WinThreshold" `
    -InstallDns:$true `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "Azerty123!" -AsPlainText -Force) `
    -Force:$true

```


- 3. Après le redémarrage, vérifier que l'AD est actif

```
 Get-ADDomain

  ```

### Étape 4 — Configuration DHCP


- 1. Installer le rôle DHCP

```

Install-WindowsFeature -Name DHCP -IncludeManagementTools

```

- 2. Autoriser le serveur DHCP dans l'AD

```
Add-DhcpServerInDC -DnsName "AD-Server.monlabo.local" -IPAddress 192.168.56.10

```

- 3. Créer l'étendue DHCP

```

Add-DhcpServerv4Scope `
    -Name "LAN Host-Only" `
    -StartRange "192.168.56.100" `
    -EndRange "192.168.56.200" `
    -SubnetMask "255.255.255.0" `
    -State Active

```

- 4. Configurer les options DHCP

```
Set-DhcpServerv4OptionValue `
    -ScopeId "192.168.56.0" `
    -Router "192.168.56.1" `
    -DnsServer "192.168.56.10" `
    -DnsDomain "monlabo.local"

```

- 5. Exclure les IPs réservées

```

Add-DhcpServerv4ExclusionRange `
    -ScopeId "192.168.56.0" `
    -StartRange "192.168.56.1" `
    -EndRange "192.168.56.20"

```

- 6. Vérifier

```
Get-DhcpServerv4Scope

```

### La bonne approche avant de configurer l'IP statique

```
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4


Puis **choisissez une IP statique cohérente** avec votre réseau `192.168.56.0/24` en dehors de la plage DHCP qu'on a définie :

Plage DHCP réservée : 192.168.56.100 → 192.168.56.200
IPs exclues         : 192.168.56.1   → 192.168.56.20

✅ IPs statiques disponibles pour les clients :
   192.168.56.21 → 192.168.56.99


## Donc les IPs statiques plus prudentes seraient

AD-Server     : 192.168.56.10  ✅ (déjà configuré)
Win10-Client1 : 192.168.56.21  ✅ hors plage DHCP
Win10-Client2 : 192.168.56.22  ✅ hors plage DHCP

```

> ⚠️ Piège classique : mettre une IP statique dans la plage DHCP risque un conflit d'adresse si le DHCP l'attribue à une autre machine.

----
----
----

## Configure Windows 10 Pro (Client)
---

### Étape 5 — Installation de Win10-Client1

```

1. Cliquez "Configurer pour une organisation"  
   ou "Domain join instead" en bas à gauche
2. Créez un compte local :
   - Nom : LocalAdmin
   - Mot de passe : 

```

## Configuration  Win10-Client2

- Étape 1 — Vérifier l'interface réseau

```

Get-NetAdapter

```

> Interface 1 = Reseau privé hote
> Interface 2 = NAT

- Étape 2 — Renommer la machine

```

Rename-Computer -NewName "Win10-Client2" -Force

```

- Étape 3 — Redémarrer pour appliquer le nom

```
Restart-Computer -Force

```

- Étape 4 — Supprimer l'IP DHCP actuelle

```

Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false

```

- Étape 5 — Supprimer la passerelle actuelle

```

Remove-NetRoute -InterfaceAlias "Ethernet" -Confirm:$false

```

- Étape 6 — Configurer l'IP statique

```

New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress "192.168.56.22" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.56.1"

```

- Étape 7 — Configurer le DNS vers AD-Server

```
Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet" `
    -ServerAddresses "192.168.56.10"

```

- Étape 8 — Vérifier la configuration réseau

```
Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4

```

> Doit afficher 192.168.56.22

```
Get-DnsClientServerAddress -InterfaceAlias "Ethernet"

```
> Doit afficher 192.168.56.10



- Étape 9 — Tester la connectivité avec AD-Server

```
Test-Connection 192.168.56.10

```

- Étape 10 — Synchronisation du temps

``` 
Start-Service W32Time
```


```
w32tm /config /manualpeerlist:"192.168.56.10" /syncfromflags:manual /update
```

```

w32tm /resync /force

```

```
w32tm /stripchart /computer:192.168.56.10 /samples:3


```
> L'écart doit être inférieur à 5 minutes, idéalement quelques secondes

- Étape 11 — Rejoindre le domaine

```
Add-Computer `
    -DomainName "monlabo.local" `
    -Credential (Get-Credential) `
    -Restart -Force

```

> Une fenêtre s'ouvre, entrez :
>
>>Utilisateur : MONLABO\Administrateur
>>Mot de passe : Azerty123!
>

- Étape 12 — Vérifier sur AD-Server après redémarrage

```

Get-ADComputer -Filter * | Select-Object Name

```

> Doit afficher :
>> Name
>>----
>>AD-Server
>>Win10-Client1
>>Win10-Client2
>




























