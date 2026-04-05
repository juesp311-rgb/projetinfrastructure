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
https://192.168.56.1
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



