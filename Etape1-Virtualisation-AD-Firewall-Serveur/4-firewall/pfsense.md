---
# pfsense
---


- Architecture cible

```
Internet
    │
    │ (WAN)
┌───────────┐
│  PFsense  │
└───────────┘
    │ (LAN)
    │ 192.168.56.0/24
    ├── AD-Server     192.168.56.10
    ├── Win10-Client1 192.168.56.21
    └── Win10-Client2 192.168.56.22
```
	- NIC1 (WAN) → NAT        → accès internet
	- NIC2 (LAN) → Host-Only  → réseau interne vers vos VMs

- Etapes

```
1. ISO PFsense    → à télécharger sur netgate.com
2. Une nouvelle VM VirtualBox pour PFsense
3. Reconfigurer le réseau des VMs existantes
```
---
## Insttallation PFsense
---

- Étape 1 — Boot

```
Laissez le boot se lancer automatiquement
Appuyez sur Entrée sur "Boot Multi User"
```

- Étape 2 — Copyright

```
Appuyez sur Entrée → Accept
```

- Étape 3 — Install

```
Sélectionnez : Install PFsense
Appuyez sur Entrée
```

- Étape 4 — Keymap

```
Sélectionnez : French (fr) ou Continue with default keymap
Appuyez sur Entrée

```

- Étape 5 — Partitionnement
```
Sélectionnez : Auto (UFS)
Appuyez sur Entrée
```

- Étape 6 — Fin d'installation

```
Sélectionnez : No  → quand demande d'ouvrir un shell
Sélectionnez : Reboot
```

- Puis 

```
em0 → NIC1 → WAN (NAT)
em1 → NIC2 → LAN (Host-Only vboxnet0)
```

- Should VLANs be set up now ?
```
n → Entrée
```

- Enter WAN interface name

```
em0 → Entrée
```

- Enter LAN interface name
```
em1 → Entrée
```

- Enter Optional interface name
```
Laissez vide → Entrée
```

- Do you want to proceed ?
```
y → Entrée
```

---
##  Configurez l'IP du LAN
---

> Dans le menu principal PFsense :

- 2 → Entrée  (Set interface(s) IP address)

```
2 → Entrée  (Set interface(s) IP address)
```

- Sélectionnez l'interface LAN

```
2 → Entrée  (LAN em1)
```

- Configure IPv4 via DHCP ?

```
n → Entrée
```

- Enter LAN IPv4 address
```
192.168.56.2 → Entrée
```
> Attention AD Server 192.168.56.2

- Enter LAN IPv4 subnet bit count
```
24 → Entrée
```

- Enter LAN IPv4 upstream gateway
```
Laissez vide → Entrée
```

- Configure IPv6 via DHCP6 ?
```
n → Entrée
```

- Enter LAN IPv6 address
```
Laissez vide → Entrée
```

- Do you want to enable the DHCP server on LAN ?
```
n → Entrée
```

> Le DHCP est déjà géré par votre AD-Server

- Do you want to revert to HTTP ?
```
n → Entrée
```

---
## Configure Wan
---

> C'est le WAN, laissez le en DHCP :

```
Appuyez sur Entrée → laisser vide
```


> ⚠️ Architecture révisée :
>> vboxnet0 (Linux hôte) → 192.168.56.1
>>PFsense LAN           → 192.168.56.2
>>AD-Server             → 192.168.56.10
>>Win10-Client1         → 192.168.56.21
>>Win10-Client2         → 192.168.56.22
>



---
## Accédez à l'interface web PFsense
---

- Depuis votre Linux hôte, ouvrez un navigateur et tapez :
```
https://192.168.56.2
```
> ⚠️ Acceptez le certificat SSL auto-signé


- Identifiants par défaut
```
Utilisateur : admin
Mot de passe : pfsense
```

> Assistant de configuration (Setup Wizard)

- Étape 1 — General Information
```
Hostname        : pfsense
Domain          : monlabo.local
Primary DNS     : 192.168.56.10  ← votre AD-Server
Secondary DNS   : 8.8.8.8        ← Google DNS en backup
```

- Étape 2 — Time Server
```
Timezone : Europe/Paris
```

- Étape 3 — WAN

```
Type : DHCP  ← laisser par défaut
```

- Étape 4 — LAN
```
IP      : 192.168.56.2
Subnet  : 24
```

- Étape 5 — Admin Password

```
Nouveau mot de passe :
Confirmation        : 
```

- Étape 6 — Reload
>Cliquez Reload



---
## Dashboard PFsense.
---

- Ce qu'on va configurer

```
1. Règles pare-feu LAN  → autoriser le trafic interne
2. Règles pare-feu WAN  → bloquer les accès non sollicités
3. NAT                  → permettre aux VMs d'accéder à internet
```
> Confirmez que vous voyez bien :
>> WAN → 10.0.2.15   ✅
>>LAN → 192.168.56.2 ✅
>

- Étape 1 — Règles pare-feu LAN
```
Firewall → Rules → LAN
```
>✅ Anti-lockout Rule  → accès à l'interface web garanti
>✅ IPv4 LAN → Any     → tout le trafic LAN autorisé
>✅ IPv6 LAN → Any     → tout le trafic LAN IPv6 autorisé


- Étape 2 — Vérifiez les règles WAN
```
Firewall → Rules → WAN
```

- Étape 3 — Vérifiez le NAT
```
Firewall → NAT → Outbound
```
```
Automatic Outbound NAT  ← idéal pour votre lab
Manual Outbound NAT
Hybrid Outbound NAT
```

---
## État complet de votre lab ✅
---

```
Infrastructure monlabo.local
─────────────────────────────────────────
PFsense        → 192.168.56.2   ✅ Routeur/Firewall
AD-Server      → 192.168.56.10  ✅ DC + DNS + DHCP + File Server
Win10-Client1  → 192.168.56.21  ✅ membre du domaine
Win10-Client2  → 192.168.56.22  ✅ membre du domaine

Flux réseau :
Win10-Clients → PFsense (192.168.56.2) → WAN (10.0.2.15) → Internet
```

>💡 Conseil : faites des snapshots maintenant sur toutes les VMs — votre lab est dans un état stable et fonctionnel.

```
VBoxManage snapshot "PFsense"      take "pfsense-configured" --description "PFsense WAN+LAN configuré"
VBoxManage snapshot "AD-Server"    take "lab-complet" --description "AD+DHCP+DNS+FileServer+PFsense"
VBoxManage snapshot "Win10-Client1" take "lab-complet" --description "Membre domaine + PFsense"
VBoxManage snapshot "Win10-Client2" take "lab-complet" --description "Membre domaine + PFsense"
```





---
## Test connectivité internet depuis Win10-Client1
---

- Étape 1 — Vérifiez la configuration réseau
```
ipconfig /all
```

> Vérifiez
>> ``` Passerelle par défaut : 192.168.56.2  ← doit pointer vers PFsense ```
>> ``` DNS                   : 192.168.56.10 ← doit pointer vers AD-Server ```
>

- Étape 2 — Pingez PFsense
```
ping 192.168.56.2
```

- Étape 3 — Pingez internet
```
ping 8.8.8.8
```

- Étape 4 — Testez la résolution DNS
```
Resolve-DnsName google.com
``

> ⚠️ Si l'étape 1 affiche toujours 192.168.56.1
> il faudra mettre à jour le DHCP sur AD-Server pour distribuer 192.168.56.2 comme nouvelle passerelle.


---
## Sur AD-Server via SSH
---

```
# Mettre à jour la passerelle DHCP vers PFsense
```
Set-DhcpServerv4OptionValue `
    -ScopeId "192.168.56.0" `
    -Router "192.168.56.2" `
    -DnsServer "192.168.56.10" `
    -DnsDomain "monlabo.local"
```

- Vérifiez
```
Get-DhcpServerv4OptionValue -ScopeId "192.168.56.0"
```

> Doit afficher 192.168.56.2 comme Router


---
## Sur Win10-Client1 — Forcez le renouvellement DHCP
---

```
ipconfig /release
ipconfig /renew
ipconfig /all
```
> La passerelle doit maintenant afficher 192.168.56.2

> ⚠️ Rappel : vos clients ont des IPs statiques 192.168.56.21 et 192.168.56.22 — il faudra aussi changer la passerelle manuellement sur chaque client.



** L'IP a changé car le client a pris une IP DHCP au lieu de l'IP statique après le ipconfig /release /renew. **


---
## Reconfigurez l'IP statique sur Win10-Client1
---

```
# Supprimer l'IP DHCP actuelle
Remove-NetIPAddress -InterfaceAlias "Ethernet" -Confirm:$false
Remove-NetRoute -InterfaceAlias "Ethernet" -Confirm:$false
```

```
# Reconfigurer l'IP statique avec la bonne passerelle
New-NetIPAddress `
    -InterfaceAlias "Ethernet" `
    -IPAddress "192.168.56.21" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.56.2"
```

```
# DNS vers AD-Server
Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet" `
    -ServerAddresses "192.168.56.10"
```

```
# Vérifier
ipconfig /all
```

> Doit afficher :
>> IPv4        : 192.168.56.21
>> Passerelle  : 192.168.56.2
>> DNS         : 192.168.56.10




---
## Ouvrir droit administrateur sur Win10-Client1
---


- Ouvrez une session sur Win10-Client1 avec le compte local :

```
Utilisateur : .\LocalAdmin
Mot de passe : 


Puis 

Get-LocalGroup
```
>  Vous verrez les groupes locaux de Windows 10 dont Administrateurs



-  Ajoutez jdupont
```
Add-LocalGroupMember `
    -Group "Administrateurs" `
    -Member "MONLABO\jdupont"
```

- Vérifiez
```
Get-LocalGroupMember -Group "Administrateurs"
```

> Doit afficher MONLABO\jdupont


---
## Mise en place règle firewall
---

```
# Supprimer les anciennes règles
Remove-NetFirewallRule -DisplayName "IIS HTTP" -ErrorAction SilentlyContinue
Remove-NetFirewallRule -DisplayName "IIS HTTPS" -ErrorAction SilentlyContinue

# Recréer les règles correctement
New-NetFirewallRule `
    -DisplayName "IIS HTTP" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Profile Any `
    -Action Allow

New-NetFirewallRule `
    -DisplayName "IIS HTTPS" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 443 `
    -Profile Any `
    -Action Allow

New-NetFirewallRule `
    -DisplayName "ICMP Allow" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -Profile Any `
    -Action Allow
```

