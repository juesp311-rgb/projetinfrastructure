---
# Hardening 
---

![Architecture hardening minimal](https://raw.githubusercontent.com/juesp311-rgb/projetinfrastructure/5a662dae7b6a785dd3392445d04cdd55c083e3b1/imageProjet/hardening_infra_dmz.svg)

---
## Couche 1 — PFsense
---

- La règle d'or : la DMZ ne doit jamais pouvoir initier une connexion vers le LAN. Seul le trafic légitime entrant est autorisé.
- Dans PFsense → Firewall → Rules → OPT1 (DMZ), créez ces règles dans l'ordre :
```
# Autoriser DNS vers l'AD-Server
Pass  TCP/UDP  DMZ net → 192.168.100.5  port 53

# Autoriser DHCP
Pass  UDP      DMZ net → 192.168.100.5  port 67-68

# Autoriser HTTPS intranet2
Pass  TCP      any → 192.168.100.20  ports 8080, 8443

# Bloquer tout le reste vers le LAN host-only
Block any      DMZ net → 192.168.56.0/24

# Bloquer DMZ → DMZ (isolation entre VMs si souhaité)
Block any      DMZ net → DMZ net  (optionnel)
```



----
- Q: Quel est l'objectif principal de votre DMZ ? (Select all that apply)
	- A: Héberger le serveur web (SRV-WEB), Isoler l'AD Server, Permettre l'accès depuis Internet (WAN), Bloquer tout accès entre DMZ et LAN

- Q: Quels accès voulez-vous autoriser depuis la DMZ vers le LAN (192.168.56.x) ?
	- A: Aucun (isolation totale)

	
![Règles pfsense](https://raw.githubusercontent.com/juesp311-rgb/projetinfrastructure/a42b1395136436c17a4fbb3bdf5de618886e4993/imageProjet/pfsense_dmz_rules.svg)

|   | Description             | Action | Protocol | Souce          | Destination     | Port dst |
|---|-------------------------|--------|----------|----------------|-----------------|----------|
|   | Isolation DMZ→LAN       | BLOCK  | ANY      | OPT1 subnet    | 192.168.56.0/24 | *        |
|   | HTTP/S entrant WAN→Web  | PASS   | TCP      | any            | 192.168.100.10  | 80, 443  |
|   | DNS DMZ→AD              | PASS   | TCP/UDP  | OPT1 subnet    | 192.168.100.5   | 53       |
|   | MAJ serveurs DMZ→WAN    | PASS   | TCP      | OPT1 subnet    | any             | 80, 443  |
|   | ICMP interne DMZ        | PASS   | ICMP     | OPT1 subnet    | OPT1 subnet     | —        |
|   | LDAP/Kerberos Client→AD | PASS   | TCP      | 192.168.100.50 | 192.168.100.5   | 88, 389  |
|   | Deny all (filet final)  | BLOCK  | ANY      | OPT1 subnet    | any             | *        |

- Pourquoi ces choix de protocole ?

```
ANY — uniquement pour les règles BLOCK générales (règles 1 et 7). On veut bloquer absolument tout, TCP, UDP, ICMP, peu importe.
TCP — pour HTTP/S, LDAP, Kerberos, SMB, RPC. Ces protocoles exigent une connexion établie (handshake), donc TCP uniquement.
TCP/UDP — uniquement pour le DNS (règle 3). Le DNS utilise UDP pour les requêtes normales (rapides, légères), mais bascule automatiquement sur TCP quand la réponse dépasse 512 octets (transferts de zone, DNSSEC). Il faut donc autoriser les deux.
ICMP — protocole à part dans PFsense, pas TCP ni UDP. Dans le menu déroulant vous verrez "ICMP" directement. Pour le type, choisissez "any" ou "Echo Request" selon la version de PFsense.
```

> à faire : 
>> > Désactivez aussi l'interface d'administration PFsense depuis la DMZ : Interfaces → LAN uniquement pour l'>



> Le trafic reste entièrement dans la DMZ, donc PFsense n'intervient pas du tout. Win10-Client1 (.100.50) contacte directement SRV-WEB (.100.10) sur le port 8443 — les deux machines sont sur le même segment 192.168.100.0/24, le switch virtuel VirtualBox gère ça localement.
---
##  Ce qu'il faut vérifier pour que ce soit vraiment sécurisé :
---
> Le port 8443 n'est pas dans vos règles PFsense actuelles, ce qui est normal puisqu'il ne sort pas de la DMZ. Mais assurez-vous que le pare-feu Windows de SRV-WEB n'accepte ce port que depuis 192.168.100.0/24 et pas depuis 0.0.0.0/0, sinon si quelqu'un accède un jour au SRV-WEB depuis le WAN il pourrait aussi atteindre ce service.

- 1. Vérifier les règles existantes sur le port 8443
```
Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'True'} |
Get-NetFirewallPortFilter | Where-Object {$_.LocalPort -eq '8443'}
```

- 2. Vérifier l'adresse source autorisée sur ces règles
```
Get-NetFirewallRule -DisplayName "*8443*" |
Get-NetFirewallAddressFilter |
Select-Object LocalAddress, RemoteAddress
```

> Si rien de n'affiche, aucune règle Windows Firewall n'existe pour le port 8443
- Vérifiez l'état du pare-feu Windows :
```
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```

> Name    Enabled DefaultInboundAction
> ----    ------- --------------------
> Domain    False        NotConfigured
> Private   False        NotConfigured
> Public    False        NotConfigured


```
$dmz = "192.168.100.0/24"

# RDP — accès administrateur
New-NetFirewallRule -DisplayName "RDP-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 3389 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# AD : DNS
New-NetFirewallRule -DisplayName "DNS-TCP-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 53 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

New-NetFirewallRule -DisplayName "DNS-UDP-DMZ" -Direction Inbound `
    -Protocol UDP -LocalPort 53 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# AD : Kerberos
New-NetFirewallRule -DisplayName "Kerberos-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 88 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# AD : LDAP / LDAPS
New-NetFirewallRule -DisplayName "LDAP-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 389 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

New-NetFirewallRule -DisplayName "LDAPS-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 636 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# AD : SMB / RPC
New-NetFirewallRule -DisplayName "SMB-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 445 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

New-NetFirewallRule -DisplayName "RPC-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 135 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# Intranet2
New-NetFirewallRule -DisplayName "Intranet2-8443-DMZ" -Direction Inbound `
    -Protocol TCP -LocalPort 8443 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# ICMP (ping)
New-NetFirewallRule -DisplayName "ICMP-DMZ" -Direction Inbound `
    -Protocol ICMPv4 -RemoteAddress $dmz `
    -Action Allow -Profile Any -Enabled True

# Réactiver le pare-feu seulement après
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True -DefaultInboundAction Block

Write-Host "Pare-feu réactivé. Vérification des règles actives :"
Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound'} |
    Select-Object DisplayName | Sort-Object DisplayName
```

---
## Vérifiez que tout fonctionne correctement
---

- 1. Confirmer que les règles sont bien créées
```
Get-NetFirewallRule | Where-Object {$_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound'} |
    Select-Object DisplayName | Sort-Object DisplayName
```

-  2. Vérifier l'état du pare-feu
```
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```

- 3. Tester depuis Win10-Client1 — ces accès doivent fonctionner
```
Test-NetConnection -ComputerName 192.168.100.10 -Port 8443 (= failed)
Test-NetConnection -ComputerName 192.168.100.10 -Port 443 (= failed)
Test-NetConnection -ComputerName 192.168.100.10 -Port 80 ( =true)
```

> Le port 80 fonctionne, mais 8443 et 443 échouent. Il y a deux causes possibles à distinguer :
>> Port		Résultat	 Cause probable
>> 80		True		Service HTTP actif + règle FW OK
>> 443		False		Service HTTPS pas démarré OU certificat manquant
>> 8443		False		Service pas en écoute sur ce port OU règle FW insuffisante


---
- Vérifiez d'abord ce qui écoute réellement sur SRV-WEB :
```
netstat -ano | findstr "LISTENING" | findstr ":443\|:8443\|:80"
```

> Si 443 et 8443 n'apparaissent pas dans la liste, le problème n'est pas le pare-feu — c'est que le service web (IIS, Apache, Nginx) n'écoute tout simplement pas sur ces ports.

- Vérifiez aussi quel service tourne sur SRV-WEB :
```
# Si c'est IIS
Get-WebBinding | Select-Object bindingInformation, protocol

```
 Get-WebBinding | Select-Object protocol, bindingInformation

protocol bindingInformation
-------- ------------------
http     192.168.56.20:80:intranet.monlabo.local
http     192.168.100.10:80:intranet2.monlabo.local
```


# Si c'est Apache/Nginx (Linux) — depuis Ubuntu
sudo ss -tlnp | grep -E '80|443|8443'
```

- Vérifiez ce qui tourne sur la machine :
```
# Voir tous les ports en écoute
netstat -ano | findstr "LISTENING"

# Voir les services actifs
Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object DisplayName, Name
```

> Le site est bien démarré et pointe vers C:\inetpub\intranet2. Vous pouvez maintenant exécuter le script HTTPS complet que je vous ai donné juste avant sans risque.

- Rien n'est fait côté HTTPS. Il faut tout configurer. Exécutez ce script complet :

```
Import-Module WebAdministration

# Créer le certificat auto-signé
$cert = New-SelfSignedCertificate `
    -DnsName "intranet2.monlabo.local" `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -NotAfter (Get-Date).AddYears(3)

$thumb = $cert.Thumbprint
Write-Host "Certificat créé : $thumb"

# Ajouter binding port 443
New-WebBinding -Name "intranet2" -Protocol https -Port 443 `
    -IPAddress "192.168.100.10" -HostHeader "intranet2.monlabo.local"

# Ajouter binding port 8443
New-WebBinding -Name "intranet2" -Protocol https -Port 8443 `
    -IPAddress "192.168.100.10" -HostHeader "intranet2.monlabo.local"

# Lier le certificat aux deux ports
(Get-WebBinding -Name "intranet2" -Protocol https -Port 443).AddSslCertificate($thumb, "My")
(Get-WebBinding -Name "intranet2" -Protocol https -Port 8443).AddSslCertificate($thumb, "My")

# Redémarrer IIS
Restart-Service W3SVC
Write-Host "IIS redémarré."

# Vérification finale
Write-Host "`n--- Bindings intranet2 ---"
Get-WebBinding -Name "intranet2" | Select-Object protocol, bindingInformation

Write-Host "`n--- Ports en écoute ---"
netstat -ano | findstr "LISTENING" | findstr ":80 \|:443 \|:8443 "
```


>Protocol bindingInformation                         
>-------- ------------------
>http     192.168.100.10:80:intranet2.monlabo.local
>https    192.168.100.10:443:intranet2.monlabo.local
>https    192.168.100.10:8443:intranet2.monlabo.local
>
>
>PS C:\Users\Administrateur>
>PS C:\Users\Administrateur> Write-Host "`n--- Ports en écoute ---"                                          
>
>--- Ports en écoute ---
>PS C:\Users\Administrateur> netstat -ano | findstr "LISTENING" | findstr ":80 \|:443 \|:8443 "              
>  TCP    0.0.0.0:80             0.0.0.0:0              LISTENING       4
>  TCP    [::]:80                [::]:0                 LISTENING   



```
Les bindings sont créés mais 443 et 8443 n'apparaissent pas dans netstat. Cela signifie que le certificat n'est pas correctement lié. C'est un problème courant avec AddSslCertificate via PowerShell.
```

- Liez le certificat manuellement avec netsh :
```
# Récupérer le thumbprint du certificat intranet2
$thumb = (Get-ChildItem Cert:\LocalMachine\My | 
    Where-Object {$_.Subject -like "*intranet2*"}).Thumbprint

Write-Host "Thumbprint : $thumb"

# Générer un GUID unique pour l'application
$guid = [guid]::NewGuid().ToString("B")

# Lier le certificat au port 443
netsh http add sslcert ipport=192.168.100.10:443 certhash=$thumb appid=$guid

# Lier le certificat au port 8443
netsh http add sslcert ipport=192.168.100.10:8443 certhash=$thumb appid=$guid

# Redémarrer IIS
Restart-Service W3SVC

# Vérifier
netstat -ano | findstr "LISTENING" | findstr ":443\|:8443"
netsh http show sslcert | findstr "443\|8443"
```

```
Liaisons de certificat SSL :
----------------------------



    Adresse IP:port                      : 192.168.100.10:8443
    Hachage du certificat             : 9ad3113b038f01abd70b5d5ec0f4b8e333c756e8
    ID de l'application               : {4dc3e181-e14b-4a21-b022-59fc669b0914}
    Nom du magasin de certificats :       : MY
    Vérifier la révocation des certificats clients : Enabled
    Vérifier la révocation au moyen du certificat client mis en cache uniquement : Disabled
    Vérification de l'utilisation                  : Enabled
    Heure d'actualisation de la révocation    : 0
    Délai d'attente de la récupération d'URL        : 0
    Identificateur CTL               : (null)
    Nom du magasin CTL               : (null)
    Utilisation du mappeur DS              : Disabled
    Négocier le certificat client : Disabled
    Refuser les connexions : Disabled
    Désactiver HTTP2 :Not Set
    Désactiver QUIC :Not Set
    Désactiver TLS1.2               : Not Set
    Désactiver TLS1.3 :Not Set
    Désactiver l'association OCSP :Not Set
    Activer la liaison de jeton         : Not Set
    Consigner les événements étendus          : Not Set
    Désactiver les versions existantes de TLS : Not Set
    Activer le ticket de session : Not Set
 Propriétés étendues :
    PropertyId                   : 0
    Fenêtre de réception                : 1048576
 Propriétés étendues :
    PropertyId                   : 1
    Paramètres max par cadre       : 2796202
    Paramètres max par minute        : 4294967295
 Propriétés étendues :
    PropertyId                   : 2
 Propriétés étendues :
    PropertyId                   : 3
 Propriétés étendues :
    PropertyId                   : 4

PS C:\Users\Administrateur> netsh http show sslcert ipport=192.168.100.10:443

Liaisons de certificat SSL :
----------------------------



    Adresse IP:port                      : 192.168.100.10:443
    Hachage du certificat             : 9ad3113b038f01abd70b5d5ec0f4b8e333c756e8
    ID de l'application               : {4dc3e181-e14b-4a21-b022-59fc669b0914}
    Nom du magasin de certificats :       : MY
    Vérifier la révocation des certificats clients : Enabled
    Vérifier la révocation au moyen du certificat client mis en cache uniquement : Disabled
    Vérification de l'utilisation                  : Enabled
    Heure d'actualisation de la révocation    : 0
    Délai d'attente de la récupération d'URL        : 0
    Identificateur CTL               : (null)
    Nom du magasin CTL               : (null)
    Utilisation du mappeur DS              : Disabled
    Négocier le certificat client : Disabled
    Refuser les connexions : Disabled
    Désactiver HTTP2 :Not Set
    Désactiver QUIC :Not Set
    Désactiver TLS1.2               : Not Set
    Désactiver TLS1.3 :Not Set
    Désactiver l'association OCSP :Not Set
    Activer la liaison de jeton         : Not Set
    Consigner les événements étendus          : Not Set
    Désactiver les versions existantes de TLS : Not Set
    Activer le ticket de session : Not Set
 Propriétés étendues :
    PropertyId                   : 0
    Fenêtre de réception                : 1048576
 Propriétés étendues :
    PropertyId                   : 1
    Paramètres max par cadre       : 2796202
    Paramètres max par minute        : 4294967295
 Propriétés étendues :
    PropertyId                   : 2
 Propriétés étendues :
    PropertyId                   : 3
 Propriétés étendues :
    PropertyId                   : 4
```

> Les certificats sont bien liés sur les deux ports. Faites maintenant le redémarrage complet de IIS :
```
Stop-Service W3SVC
Stop-Service WAS
Start-Service WAS
Start-Service W3SVC
Start-Sleep -Seconds 5
netstat -ano | findstr "LISTENING" | findstr ":443\|:8443\|:80"
```


- Résultat 
```
PS C:\> Test-NetConnection -ComputerName 192.168.100.10 -Port 443                                               


ComputerName     : 192.168.100.10
RemoteAddress    : 192.168.100.10
RemotePort       : 443
InterfaceAlias   : Ethernet 3
SourceAddress    : 192.168.100.10
TcpTestSucceeded : True



PS C:\> Test-NetConnection -ComputerName 192.168.100.10 -Port 8443                                              


ComputerName     : 192.168.100.10
RemoteAddress    : 192.168.100.10
RemotePort       : 8443
InterfaceAlias   : Ethernet 3
SourceAddress    : 192.168.100.10
TcpTestSucceeded : True

```
- Testez maintenant depuis Win10-Client1 (192.168.100.50) pour valider le chemin complet à travers le réseau :
```
Test-NetConnection -ComputerName 192.168.100.10 -Port 443 (ok)
Test-NetConnection -ComputerName 192.168.100.10 -Port 8443 (ok)
Test-NetConnection -ComputerName 192.168.100.10 -Port 80 (non sécurisé)
```


---
## Récapitulatif de ce qui a été accompli aujourd'hui :
---

| Service                             | Accès     |
|-------------------------------------|-----------|
| Règles PFsense OPT1 (DMZ)           | Configuré |
| Ports AD Windows Firewall           | Configuré |
| Pare-feu Windows SRV-WEB réactivé   | Fait      |
| Certificat SSL auto-signé intranet2 | Créé      |
| Bindings IIS 80 / 443 / 8443        | Configuré |
| Permissions clé privée CNG          | Corrigé   |


| Service        | Accès              | Sécurité           |
|----------------|--------------------|--------------------|
| intranet2:80   | DMZ uniquement     | HTTP non chiffré   |
| intranet2:443  | DMZ uniquement     | HTTPS + certificat |
| intranet2:8443 | DMZ uniquement     | HTTPS + certificat |
| LAN → DMZ      | Bloqué par PFsense | Isolation OK       |
| DMZ → LAN      | Bloqué par PFsense | Isolation OK       |











---
## Couche 2 — AD-Server (GPO)
---


- Configuration actuelle
```
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction
```
```
Name    Enabled DefaultInboundAction
----    ------- --------------------
Domain     True        NotConfigured
Private    True        NotConfigured
Public     True        NotConfigured
```
```
Votre compte 
...

Windows Management Instrumentation (ASync-In)

Windows Management Instrumentation (DCOM-In)

Windows Management Instrumentation (WMI-In)

Windows Search
```

```
 netstat -ano | findstr "LISTENING" | findstr ":53\|:88\|:389\|:636\|:445\|:135"

PS C:\Users\Administrateur> 
```

- AD-Server 
```
# Vérifier les services AD
Get-Service adws, dns, kdc, netlogon, ntds | Select-Object Name, Status, DisplayName

# Vérifier si le rôle AD DS est installé
Get-WindowsFeature AD-Domain-Services | Select-Object Name, Installed, InstallState
```

```
PS C:\Users\Administrateur> Get-Service adws, dns, kdc, netlogon, ntds | Select-Object Name, Status, DisplayName


Name      Status DisplayName                            
----      ------ -----------                            
adws     Running Services Web Active Directory          
dns      Running Serveur DNS                            
kdc      Running Centre de distribution de clés Kerberos
Netlogon Running netlogon                               
ntds     Running Services de domaine Active Directory   


PS C:\Users\Administrateur> 
PS C:\Users\Administrateur> # Vérifier si le rôle AD DS est installé
PS C:\Users\Administrateur> Get-WindowsFeature AD-Domain-Services | Select-Object Name, Installed, InstallState

Name               Installed InstallState
----               --------- ------------
AD-Domain-Services      True    Installed
```


- Et vérifiez directement depuis Win10-Client1 si l'AD répond :
```
Test-NetConnection -ComputerName 192.168.100.5 -Port 53 (failed, timedOut, false)
Test-NetConnection -ComputerName 192.168.100.5 -Port 88 (failed, timedOut, false)
Test-NetConnection -ComputerName 192.168.100.5 -Port 389 (failed, timedOUt, false)
```
-  l'AD Server n'a pas de passerelle et ne peut pas communiquer hors de son segment. Ajoutez la passerelle depuis l'AD Server :
```
# Identifier le nom de l'interface DMZ
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway

# Ajouter la passerelle sur l'interface DMZ
New-NetRoute -InterfaceAlias "Ethernet 3" -DestinationPrefix "0.0.0.0/0" -NextHop 192.168.100.2
```

> L'AD peut joindre SRV-WEB (.100.10) mais pas Win10-Client1 (.100.50). Puisque les deux sont dans la même DMZ, le problème vient du pare-feu Windows de Win10-Client1 qui bloque le ICMP.

- Vérifiez depuis Win10-Client1 :
```
# État du pare-feu
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction

# Règle ICMP existante ?
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*ICMP*" -and $_.Enabled -eq 'True'}
```

> Depuis Win10-Client Ping Failed

```
# Autoriser ICMP depuis la DMZ uniquement
New-NetFirewallRule `
    -DisplayName "ICMP-DMZ-IN" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -RemoteAddress "192.168.100.0/24" `
    -Action Allow `
    -Enabled True

# Tester
ping 192.168.100.50 (ok)
```


- Testez les ports AD depuis Win10-Client1 vers l'AD
```
Test-NetConnection -ComputerName 192.168.100.5 -Port 88 (true)
Test-NetConnection -ComputerName 192.168.100.5 -Port 389 (true)
```

- Ce qui reste à faire sur l'AD Server :
> Le pare-feu Windows de l'AD est encore en mode NotConfigured (permissif)





- Ouvrez Group Policy Management sur l'AD-Server et créez une GPO Securite-Baseline liée au domaine monlabo.local.

```
# Politique de mots de passe



# Configurer le verrouillage via PowerShell
Import-Module ActiveDirectory

Set-ADDefaultDomainPasswordPolicy `
    -Identity "monlabo.local" `
    -LockoutThreshold 5 `
    -LockoutDuration 00:30:00 `
    -LockoutObservationWindow 00:15:00

# Vérifier
Get-ADDefaultDomainPasswordPolicy | 
    Select-Object LockoutThreshold, LockoutDuration, LockoutObservationWindow
```
| Paramètre                    | Valeur recommandée | Explication                |
|------------------------------|--------------------|----------------------------|
| Seuil de verrouillage        | 5 tentatives       | Bloque après 5 échecs      |
| Durée de verrouillage        | 30 minutes         | Déverrouillage automatique |
| Réinitialisation du compteur | 15 minutes         | Remet le compteur à zéro   |


- Audit des accès 
	- apprend à lire les logs Windows. 

```
# Activer l'audit via GUID (fonctionne quelle que soit la langue)
auditpol /set /subcategory:"{0cce9215-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
auditpol /set /subcategory:"{0cce9216-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
auditpol /set /subcategory:"{0cce9217-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable
auditpol /set /subcategory:"{0cce9235-69ae-11d9-bed3-505054503030}" /success:enable /failure:enable

# Vérifier
auditpol /get /category:*
```

- Maintenant consultez les logs pour voir quelles machines se connectent :

```
# Voir les 20 dernières connexions réussies
Get-EventLog -LogName Security -InstanceId 4624 -Newest 20 |
    Select-Object TimeGenerated, @{N="Machine";E={$_.ReplacementStrings[11]}},
    @{N="Utilisateur";E={$_.ReplacementStrings[5]}},
    @{N="IP";E={$_.ReplacementStrings[18]}} |
    Format-Table -AutoSize

# Voir les 20 derniers échecs de connexion
Get-EventLog -LogName Security -InstanceId 4625 -Newest 20 |
    Select-Object TimeGenerated, @{N="Utilisateur";E={$_.ReplacementStrings[5]}},
    @{N="IP";E={$_.ReplacementStrings[19]}},
    @{N="Raison";E={$_.ReplacementStrings[8]}} |
    Format-Table -AutoSize
```

| ID Evenements | Signification      |
|---------------|--------------------|
| 4624          | Connexion réussie  |
| 4625          | Échec de connexion |
| 4634          | Déconnexion        |
| 4740          | Compte verrouillé  |



---
## Principe de la DMZ
---

| Scénario                   | Sans DMZ                      | Avec votre DMZ                    |
|----------------------------|-------------------------------|-----------------------------------|
| Hacker accède au SRV-WEB   | Accès direct au LAN et à l'AD | Bloqué par PFsense (règle 1)      |
| Hacker compromet SRV-WEB   | Peut attaquer l'AD            | Isolé — ne voit pas le LAN        |
| Hacker tente LDAP/Kerberos | Accès direct à l'AD           | Limité à 192.168.100.5 uniquement |
| Hacker scanne le réseau    | Voit tout                     | Ne voit que la DMZ                |






| Protection                                      | Mécanisme                          |
|-------------------------------------------------|------------------------------------|
| SRV-WEB compromis ne peut pas atteindre le LAN  | Règle BLOCK PFsense DMZ→LAN        |
| L'AD n'est accessible que sur ports nécessaires | Règles PFsense + Windows Firewall  |
| Tout trafic non autorisé est bloqué             | Deny all en dernière règle PFsense |
| Logs des tentatives d'intrusion                 | Audit AD activé                    |
| Double protection sur chaque serveur            | PFsense + Windows Firewall local   |



> Un hacker doit donc contourner deux pare-feux successifs avant d'atteindre un service, et même s'il compromet SRV-WEB, il reste prisonnier de la DMZ sans accès au LAN ni à l'AD.





---
## Couche 3 — Ubuntu / Nginx
---

---
### Vérification de l'environnement
---


- Informations sur le serveur web (SRV-WEB)
```
$webServer = "SRV-WEB"
$webServerOS = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $webServer).Caption
$webSite = "https://intranet2.monlabo.local"

Write-Host "Serveur Web (SRV-WEB) :"
Write-Host "  - Système d'exploitation : $webServerOS"
Write-Host "  - Adresse IP : " (Test-Connection -ComputerName $webServer -Count 1).IPV4Address.IPAddressToString
Write-Host "  - Site web : $webSite"
```
- Informations sur le domaine Active Directory
```
$adServer = "192.168.100.5"
$adDomain = (Get-ADDomain -Server $adServer).DNSRoot

Write-Host "Domaine Active Directory :"
Write-Host "  - Serveur AD : $adServer"
Write-Host "  - Nom de domaine AD : $adDomain"
```

- Informations sur le pare-feu pfSense
```
$pfSenseIP = "192.168.100.2"

Write-Host "Pare-feu pfSense :"
Write-Host "  - Adresse IP (DMZ) : $pfSenseIP"
```

- Informations sur un poste client (exemple : Win10-Client1)
```
$clientName = "Win10-Client1"
$clientIP = (Test-Connection -ComputerName $clientName -Count 1).IPV4Address.IPAddressToString
$clientGateway = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true" -ComputerName $clientName).DefaultIPGateway

Write-Host "Poste client (Win10-Client1) :"
Write-Host "  - Adresse IP : $clientIP"
Write-Host "  - Passerelle par défaut : $clientGateway"
```

- Résolution DNS
```
$dnsServers = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=$true" -ComputerName $clientName).DNSServerSearchOrder
$dnsResult = Resolve-DnsName -Name $webSite -Server $dnsServers[0] -DnsOnly -NoHostsFile -ErrorAction SilentlyContinue

Write-Host "Résolution DNS :"
Write-Host "  - Serveurs DNS configurés sur le poste client : $dnsServers"
if ($dnsResult) {
    Write-Host "  - Résolution de $webSite : " $dnsResult.IPAddress
} else {
    Write-Host "  - Résolution de $webSite : échec"
}
```

- Information sur Ubuntu Server (Nginx)

```
# Fichiers de configuration Nginx :
sudo cat /etc/nginx/nginx.conf
   sudo ls -l /etc/nginx/sites-available/
   sudo cat /etc/nginx/sites-available/intranet2.monlabo.local

# Informations sur le certificat SSL :
sudo grep -E 'ssl_certificate|ssl_certificate_key' /etc/nginx/sites-available/intranet2.monlabo.local
   sudo openssl x509 -in /path/to/your/certificate.crt -noout -issuer -enddate

# Remplacez /path/to/your/certificate.crt par le chemin vers votre fichier de certificat.

# En-têtes de sécurité HTTP configurés :

sudo grep -E 'add_header' /etc/nginx/sites-available/intranet2.monlabo.local


# Version de Nginx :
nginx -v

# Version d'OpenSSL utilisée par Nginx :
nginx -V 2>&1 | grep OpenSSL

# Plugins ou modules Nginx installés :
nginx -V 2>&1 | grep 'configure arguments:'


# Emplacement des logs Nginx :
sudo grep -E 'access_log|error_log' /etc/nginx/nginx.conf
   sudo grep -E 'access_log|error_log' /etc/nginx/sites-available/intranet2.monlabo.local


```


```
---
#### éléments de sécurité applicative pour votre site web
---

> Les headers HTTP sécurisés
> HSTS (HTTP Strict Transport Security)
> La redirection HTTP vers HTTPS
> Le certificat SSL renforcé
> La mise en place d'une politique de sécurité des contenus (CSP)

- Headers HTTP sécurisés (Haute priorité) :
```
$websiteName = "intranet2.monlabo.local"
$headers = @{
  'X-XSS-Protection' = '1; mode=block'
  'X-Frame-Options' = 'SAMEORIGIN'  
  'X-Content-Type-Options' = 'nosniff'
  'Referrer-Policy' = 'strict-origin-when-cross-origin'
  'Permissions-Policy' = 'geolocation=(), microphone=()'
}

foreach ($key in $headers.Keys) {
  $existingHeader = Get-WebConfigurationProperty -PSPath "IIS:\Sites\$websiteName" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='$key']" -Name "."
  if ($existingHeader) {
    Clear-WebConfiguration -PSPath "IIS:\Sites\$websiteName" -Filter "system.webServer/httpProtocol/customHeaders/add[@name='$key']"
  }
  Add-WebConfigurationProperty -PSPath "IIS:\Sites\$websiteName" -Filter "system.webServer/httpProtocol/customHeaders" -Name "." -Value @{name=$key; value=$headers[$key]}
}
```














-----------------------------
------------------------------
-------------------------------
--------------------------------
- UFW (firewall local)

```
# Réinitialiser et configurer UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH (restreint à votre réseau host-only)
sudo ufw allow from 192.168.56.0/24 to any port 22

# Autoriser les ports intranet2
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp

# Activer
sudo ufw enable
sudo ufw status verbose
```

- fail2ban (protection SSH)
```
sudo apt install fail2ban -y

# Créer la config locale (ne jamais modifier jail.conf)
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

- Modifiez la section [sshd] :
```
[sshd]
enabled  = true
port     = 22
maxretry = 5
bantime  = 3600
findtime = 600
```
```
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

# Vérifier
sudo fail2ban-client status sshd
```

- Headers de sécurité Nginx
	- Ajoutez dans votre vhost /etc/nginx/sites-available/intranet2 dans le bloc server HTTPS :
```
# Headers de sécurité
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;

# Masquer la version de Nginx
server_tokens off;
```

---
## Couche 4 — SRV-Web (IIS) et clients
---

- Forcer HTTPS sur IIS
```
# Supprimer tout binding HTTP résiduel sur SRV-Web
# Vérifier qu'aucun port 80 n'est exposé directement aux clients
# (Nginx fait déjà la redirection, IIS ne doit répondre qu'à Nginx)

# Restreindre IIS à n'accepter que depuis Ubuntu (192.168.100.20)
New-NetFirewallRule `
    -DisplayName "IIS Inbound Nginx Only" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -RemoteAddress 192.168.100.20 `
    -Action Allow `
    -Profile Any

# Supprimer l'ancienne règle trop permissive
Remove-NetFirewallRule -DisplayName "HTTP Inbound DMZ"
```

- GPO pour Win10-Client1
```
# Dans Group Policy Management, nouvelle GPO "Securite-Clients"
# Quelques mesures simples pour le lab :

Computer Config → Admin Templates → System → Removable Storage :
    All removable storage classes : Deny all access → Enabled

Computer Config → Windows Settings → Security Settings → Local Policies :
    Interactive logon: Display user information → Do not display user information

# Désactiver PowerShell v2 (vecteur d'attaque courant)
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
```


---
## Récapitulatif
---

- Couche 1 — PFsense DMZ
```
7 règles firewall configurées
Isolation DMZ → LAN validée
```


- Couche 2 — Windows Firewall
```
SRV-WEB durci + IIS HTTPS opérationnel
AD Server durci + audit des accès activé
Verrouillage des comptes configuré
```

- Couche 3 — En cours
```
web.config avec headers sécurisés à valider au retour
```





---
## Checklist rapide pour valider le hardening
---

```
# Depuis Ubuntu — vérifier que PFsense bloque bien DMZ → LAN
ping 192.168.56.10   # doit être bloqué (timeout)
ping 192.168.100.5   # doit répondre (même DMZ)

# Vérifier fail2ban actif
sudo fail2ban-client status

# Vérifier UFW
sudo ufw status

# Vérifier headers Nginx
curl -I https://intranet2.monlabo.local:8443 --insecure
# Doit afficher Strict-Transport-Security, X-Frame-Options, etc.
```

