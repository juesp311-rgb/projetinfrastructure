---
# Nginx
---
---
## Pré-requis
---
> Sur Virtualbox : 
>>monlabo.local

```
├── PFsense
LAN : 192.168.56.2-24,
OPT1(=DMZ) : 192.3168.100.2/24
WAN : 10.0.2.15/24						

├── AD-Server: 
Carte Ethernet Ethernet : reseau privé hote

   Adresse IPv4. . . . . . . . . . . . . .: 192.168.56.10
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Passerelle par défaut. . . . . . . . . : 192.168.56.1

Carte Ethernet Ethernet 2 : NAT 

   Adresse IPv4. . . . . . . . . . . . . .: 10.0.3.15
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Passerelle par défaut. . . . . . . . . : fe80::2%3
                                       10.0.3.2

Carte Ethernet Ethernet 3 : reseau interne, connecté à la DMZ

   Adresse IPv4. . . . . . . . . . . . . .: 192.168.100.5
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Passerelle par défaut. . . . . . . . . :

nslookup mon.labo.local : Nom :    monlabo.local
Addresses:  fd17:625c:f037:3:c0e8:6362:1383:7629
          192.168.100.5
          192.168.56.10
          10.0.3.15


│                                   DNS : intranet.monlabo.local
├── SRV-Web
192.168.56.20  → IIS + SQL Server

PS C:\Users\Administrateur> whoami                         
srv-web\administrateur


  C:\Users\Administrateur> ipconfig        
 Configuration IP de Windows
Carte Ethernet Ethernet :                                                                                              
Adresse IPv4. . . . . . . . . . . . . .: 192.168.56.20     
Masque de sous-réseau. . . . . . . . . : 255.255.255.0     
Passerelle par défaut. . . . . . . . . : 192.168.56.2                                                              
Carte Ethernet Ethernet 2 : NAT                                                                                            
 Adresse IPv4. . . . . . . . . . . . . .: 10.0.3.15        
 Masque de sous-réseau. . . . . . . . . : 255.255.255.0     
Passerelle par défaut. . . . . . . . . : fe80::2%7                                            
 10.0.3.2                                                                     

Carte Ethernet Ethernet 3 :
  Adresse IPv4. . . . . . . . . . . . . .: 192.168.100.10   
 Masque de sous-réseau. . . . . . . . . : 255.255.255.0    
 Passerelle par défaut. . . . . . . . . : 192.168.100.2  


│       http://intranet.monlabo.local
├── Win10-Client1  192.168.56.21  → Poste jdupont ✅
└── Win10-Client2  192.168.56.22  → Poste non configuré
```


---
## Pfsense
---

- Régles initial

[LAN](https://github.com/juesp311-rgb/projetinfrastructure/blob/main/imageProjet/pfsensefirewallrule1.png)
[OPT](https://github.com/juesp311-rgb/projetinfrastructure/blob/main/imageProjet/pfsensefirewall2.png)



> Ajout règle
- Règle 1 — Nginx DMZ → IIS SRV-Web (port 80)
```
Action   : Pass
Protocol : TCP
Source   : 192.168.100.20  (Ubuntu Nginx)
Dest     : 192.168.100.10  (SRV-Web interface DMZ)
Port dst : 80
Description : Nginx proxy → IIS intranet2
```

- Règle 2 — Clients DMZ → Nginx (port 80)
```
Action   : Pass
Protocol : TCP
Source   : 192.168.100.0/24
Dest     : 192.168.100.20  (Nginx)
Port dst : 80
Description : Clients DMZ → Nginx reverse proxy
```
- Règle 3 — Nginx LAN → IIS SRV-Web (port 80)
```
Action   : Pass
Protocol : TCP
Source   : 192.168.56.30   (Ubuntu Nginx interface LAN)
Dest     : 192.168.56.20   (SRV-Web interface LAN)
Port dst : 80
Description : Nginx proxy → IIS intranet
```

- Résultats 
** ✅ Règles OPT1 (DMZ) ** 

```
Règle			Source			Destination		Port	Statut
DNS 			TCP192.168.100.0/24	192.168.56.10		53	✅
Kerberos		192.168.100.0/24	192.168.56.10		88	✅
LDAP x2			192.168.100.0/24	192.168.56.10		389	✅
MS DS			192.168.100.0/24	192.168.56.10		445	✅
RPC			192.168.100.0/24	192.168.56.10		135	✅
DMZ→LAN			192.168.100.0/24	192.168.56.0/24		*	❌ désactivée
Nginx→IIS		192.168.100.20		192.168.100.10		80	✅ nouvelle
Clients→Nginx		192.168.100.0/24	192.168.100.20		80	✅ nouvelle
```
** ✅ Règles LAN **
```
Règle			Source			Destination		Port	Statut
Default allow LAN	LAN subnets		*			*	✅
LAN→OPT1		LAN subnets		OPT1 subnets		*	✅
LAN→OPT1		LAN subnets		OPT1 subnets		*	❌ désactivée
Nginx→IIS		192.168.56.30		192.168.56.20		80	✅ nouvelle
```

---
## Reverse proxe en DMZ
---

```
Internet / WAN
      ↓
   PFsense
      ↓
    DMZ (192.168.100.x)
  [ Nginx Reverse Proxy ]
      ↓
    LAN (192.168.56.x)
  [ SRV-Web IIS ]  [ AD-Server ]
```


---
## UbuntuServer 
---

- Étape 1 — Connecter l'Ubuntu Server au bon réseau VirtualBox

```
Carte		Interface		Réseau			État
enp0s3		Réseau privé hôte	192.168.56.101 (DHCP)	✅ UP
enp0s8		NAT			
enp0s9		192.168.100.20		DMZ réseau interne	✅ UP

```
> Si Interface DOWN
```
sudo ip link set enp0s8 up
sudo networkctl up enp0s8
sudo netplan apply


- Étape 2 — Configurer l'IP statique sur Ubuntu


```
sudo nano /etc/netplan/00-installer-config.yaml
```
network:
  version: 2
  ethernets:
    enp0s3:          # réseau privé hôte → IP fixe
      dhcp4: no
      addresses:
        - 192.168.56.30/24
      nameservers:
        addresses: [192.168.56.10]   # AD-Server
    enp0s8:          # NAT → internet pour apt
      dhcp4: yes
```
>> ⚠️ Pas de routes: default sur enp0s3 — la gateway par défaut viendra du NAT (enp0s8 via DHCP). Sinon les deux cartes se battent pour la route par défaut.



> Appliquez :
```
sudo netplan apply
```
> Vérifications
```
ip a                        # enp0s3 doit afficher 192.168.56.30/24
ping 192.168.56.10          # AD-Server
ping 192.168.56.20          # SRV-Web
ping 8.8.8.8                # internet via enp0s8
```


- Étape 3 — Installer Nginx
```
sudo apt update && sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

> Vérifiez qu'il tourne :
```
sudo systemctl status nginx
```

- Étape 4 — Configurer un virtual host par service
> Nginx utilise un fichier de config par site dans /etc/nginx/sites-available/. On va en créer un pour intranet.monlabo.local qui redirige vers votre SRV-Web.

```
sudo nano /etc/nginx/sites-available/intranet.monlabo.local
```
> Collez ceci :
```
server {
    listen 80;
    server_name intranet.monlabo.local;

    location / {
        proxy_pass http://192.168.56.20;        # SRV-Web IIS
        proxy_http_version 1.1;

        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> Activez ce site et désactivez la page par défaut :
```
sudo ln -s /etc/nginx/sites-available/intranet.monlabo.local \
           /etc/nginx/sites-enabled/

sudo rm /etc/nginx/sites-enabled/default
```

> Testez la syntaxe, puis rechargez :
```
sudo nginx -t
sudo systemctl reload nginx
```

- Test depuis le PC hôte
```
curl -H "Host: intranet.monlabo.local" http://192.168.56.30
```

---
## Mise en place de l'intranet2
---

- Configure Netplan
```
sudo nano /etc/netplan/00-installer-config.yaml
```

```
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.56.30/24
      nameservers:
        addresses: [192.168.56.10]
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.100.20/24
```

- Appliquez :
```
sudo netplan apply
ip a | grep 192.168
```

- Changez listen 80; par :

```
server {
    listen 192.168.56.30:80;
    server_name intranet.monlabo.local;

    location / {
        proxy_pass http://192.168.56.20;
        proxy_http_version 1.1;

        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

> Puis
```
 sudo nginx -t
sudo systemctl restart nginx
sudo ss -tlnp | grep nginx
```

> Résultat
```
192.168.56.30:80    → intranet  (LAN)
192.168.100.20:80   → intranet2 (DMZ)
```

- Testez les deux :
```
# Test intranet via LAN
curl -H "Host: intranet.monlabo.local" http://192.168.56.30

# Test intranet2 via DMZ
curl -H "Host: intranet2.monlabo.local" http://192.168.100.20
```

---
## Mettre à jour le DNS sur l'AD-Server
---

```
# intranet → pointe vers Nginx LAN
Remove-DnsServerResourceRecord -ZoneName "monlabo.local" -Name "intranet" -RRType "A" -Force
Add-DnsServerResourceRecordA -ZoneName "monlabo.local" -Name "intranet" -IPv4Address "192.168.56.30"

# intranet2 → pointe vers Nginx DMZ
Remove-DnsServerResourceRecord -ZoneName "monlabo.local" -Name "intranet2" -RRType "A" -Force
Add-DnsServerResourceRecordA -ZoneName "monlabo.local" -Name "intranet2" -IPv4Address "192.168.100.20"

# Vérification
Resolve-DnsName "intranet.monlabo.local"
Resolve-DnsName "intranet2.monlabo.local"
```


---
##  Win10-Client1 :
---

- Dans PFsense → Firewall → Rules → LAN, ajoutez :
```
Action      : Pass
Protocol    : TCP
Source      : LAN subnets
Destination : 192.168.100.20  (Nginx DMZ)
Port dst    : 80
Description : Clients LAN → Nginx intranet2
```

- Vérifiez le firewall Ubuntu
```
# Vérifier si UFW est actif
sudo ufw status

# Si actif, autoriser le port 80
sudo ufw allow 80/tcp
sudo ufw status
```

> http://intranet.monlabo.local OK

###  Configure intranet2

- 1. Configure carte réseau
	- Reseau interne > DMZ

```
ip a 
> Vérifier state interface DOWN ou UP

# Monter enp0s9 avant d'appliquer
sudo ip link set enp0s9 up

# Appliquer la config
sudo netplan apply

# Vérifier
ip a | grep 192.168
# Résultat attendu :
# 192.168.56.30 → enp0s3 (LAN)  ✅
# 192.168.100.20 → enp0s9 (DMZ) ✅
```

- Netplan — assigner les IPs
```
sudo nano /etc/netplan/50-cloud-init.yaml
```
```
network:
  version: 2
  ethernets:
    enp0s3:          # Réseau privé hôte - LAN
      dhcp4: no
      addresses:
        - 192.168.56.30/24
      nameservers:
        addresses: [192.168.56.10]
    enp0s8:          # NAT - internet
      dhcp4: yes
    enp0s9:          # Réseau interne DMZ
      dhcp4: no
      addresses:
        - 192.168.100.20/24
```

- 3. Nginx — virtual host intranet et interface

> Vérifier 
```
sudo ss -tlnp | grep nginx
```

```
sudo nano /etc/nginx/sites-available/intranet.monlabo.local
```

```
server {
    listen 192.168.56.30:80;      # ← spécifique LAN
    server_name intranet.monlabo.local;

    location / {
        proxy_pass http://192.168.56.20;
        proxy_http_version 1.1;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```
sudo nano /etc/nginx/sites-available/intranet2.monlabo.local
```
```
server {
    listen 192.168.100.20:80;     # ← spécifique DMZ
    server_name intranet2.monlabo.local;

    location / {
        proxy_pass http://192.168.100.10;
        proxy_http_version 1.1;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```
sudo nginx -t
sudo systemctl restart nginx

# Vérifier — deux lignes distinctes
sudo ss -tlnp | grep nginx
# 192.168.56.30:80  ✅
# 192.168.100.20:80 ✅
```


> Quand Nginx a plusieurs virtual hosts sur des interfaces différentes, chaque listen doit spécifier l'IP exacte, sinon tout se fusionne sur 0.0.0.0:80.

- 5. UFW — firewall Ubuntu 
```
# Vérifier l'état UFW
sudo ufw status

# Résultat : seul OpenSSH était autorisé
# Correction :
sudo ufw allow 80/tcp
sudo ufw status
# 80/tcp ALLOW Anywhere ✅
```



- 6. Win10 — Configure route 

```
# Diagnostic :
Test-NetConnection -ComputerName 192.168.100.20 -Port 80
```
`
- Ajouter la route vers la DMZ via PFsense LAN :
```
# Route temporaire
route add 192.168.100.0 mask 255.255.255.0 192.168.56.2

# Route permanente (persiste après redémarrage)
route add 192.168.100.0 mask 255.255.255.0 192.168.56.2 -p

# Vérification
Test-NetConnection -ComputerName 192.168.100.20 -Port 80
# InterfaceAlias : Ethernet    ← carte LAN ✅
# SourceAddress  : 192.168.56.21 ✅
# TcpTestSucceeded : True ✅
```

> Quand une machine a plusieurs cartes réseau, Windows choisit la route par défaut selon la métrique. Si la carte NAT a une métrique plus basse, tout le trafic passe par elle — même vers des réseaux qui devraient passer par le LAN. Il faut ajouter des routes statiques explicites.



















---
## Récap complet de ce qui est en place 🏆
---

Composant		Rôle			Statut
Ubuntu 192.168.56.30	Nginx LAN		✅
Ubuntu 192.168.100.20	Nginx DMZ		✅
intranet.monlabo.local	→ IIS LAN via Nginx	✅
intranet2.monlabo.local	→ IIS DMZ via Nginx	✅
DNS AD-Server		Pointe vers Nginx	✅
PFsense règles LAN	Autorise LAN → DMZ:80	✅
Win10-Client1		Accès aux deux intranets✅



---
## Prochaines étapes possibles
---

- HTTPS — certificat auto-signé sur Nginx
- Logs — configurer les access logs Nginx par virtual host
- Win10-Client2 — configurer le deuxième poste
- Sécurité PFsense — changer le mot de passe par défaut
