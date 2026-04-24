---
#  HTTPS avec un certificat auto-signé et les logs par virtual host sur ton Nginx Ubuntu.
---

---
## Pré-requis
---

** Réseau sur Virtualbox **  

- PC Hote
wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500   inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255 
-
 
- ├── PFsense
```
LAN : 192.168.56.2/24,
OPT1(=DMZ) : 192.168.100.2/24
WAN : 10.0.2.15/24                        
```

- ├── AD-Server: monlabo.local
```
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

│     DNS : intranet.monlabo.local

```

- ├── SRV-Web
```
Ip : 192.168.56.20  → IIS + SQL Server
 Configuration IP de Windows
Carte Ethernet Ethernet :                                                                                              
Adresse IPv4. . . . . . . . . . . . . .: 192.168.56.20     
Masque de sous-réseau. . . . . . . . . : 255.255.255.0     
Passerelle par défaut. . . . . . . . . : 192.168.56.2                                                              

Carte Ethernet Ethernet 2 : NAT                                                                                            
 Adresse IPv4. . . . . . . . . . . . . .: 10.0.3.15        
 Masque de sous-réseau. . . . . . . . . : 255.255.255.0     
Passerelle par défaut. . . . . . . . . : fe80::2%7                                            
 10.0.3.2                                                                     

Carte Ethernet Ethernet 3 :
  Adresse IPv4. . . . . . . . . . . . . .: 192.168.100.10   
 Masque de sous-réseau. . . . . . . . . : 255.255.255.0    
 Passerelle par défaut. . . . . . . . . : 192.168.100.2  

│       http://intranet.monlabo.local
	http://intranet2.monlabo.local

```
- ├── Win10-Client1  192.168.56.21  → Poste jdupont ✅

- └── Win10-Client2  192.168.56.22  → Poste non configuré


- VM Ubuntu
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
##  ma config nginx : 
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

- Récap complet de ce qui est en place 🏆
```
ComposantRôleStatutUbuntu
192.168.56.30Nginx LAN✅
Ubuntu 192.168.100.20Nginx DMZ✅
intranet.monlabo.local→ IIS LAN via Nginx✅
intranet2.monlabo.local→ IIS DMZ via Nginx✅DNS 
AD-ServerPointe vers Nginx✅
PFsense règles LANAutorise LAN → DMZ:80✅
Ubuntu > Nginx
Win10-Client1Accès aux deux intranets
```

- Prochaines étapes
	- HTTPS — certificat auto-signé sur Nginx
	- Logs — configurer les access logs Nginx par virtual host

---
## https
---

- 1. Génération du certificat auto-signé
> VM Ubuntu

```
# Crée le répertoire dédié
sudo mkdir -p /etc/nginx/ssl

# Génère la clé privée et le certificat (valide 2 ans)
sudo openssl req -x509 -nodes -days 730 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out    /etc/nginx/ssl/nginx.crt \
  -subj "/C=FR/ST=Centre/L=Mer/O=MonLabo/CN=*.monlabo.local" \
  -addext "subjectAltName=DNS:intranet.monlabo.local,DNS:intranet2.monlabo.local,IP:192.168.56.30,IP:192.168.100.20"

# Sécurise les permissions
sudo chmod 600 /etc/nginx/ssl/nginx.key
sudo chmod 644 /etc/nginx/ssl/nginx.crt
```

- 2. Configuration Nginx HTTPS — LAN (intranet.monlabo.local) (en cours)

- 3. Configuration Nginx HTTPS — DMZ (intranet2.monlabo.local)
```
sudo nano /etc/nginx/sites-available/intranet2.monlabo.local
```
# Redirection HTTP → HTTPS
server {
    listen 192.168.100.20:80;
    server_name intranet2.monlabo.local;
    return 301 https://$host$request_uri;
}

# HTTPS
server {
    listen 192.168.100.20:443 ssl;
    server_name intranet2.monlabo.local;

    ssl_certificate     /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

    # Logs spécifiques à ce vhost
    access_log  /var/log/nginx/intranet-dmz-access.log;
    error_log   /var/log/nginx/intranet-dmz-error.log warn;

    location / {
        proxy_pass         http://192.168.100.10;
        proxy_http_version 1.1;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

- 4. Activer et tester
```
# Activer les deux sites
sudo ln -s /etc/nginx/sites-available/intranet-lan.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/intranet-dmz.conf /etc/nginx/sites-enabled/

# Vérifier la syntaxe
sudo nginx -t
> Si nginx -t retourne bien :
>> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
>> nginx: configuration file /etc/nginx/nginx.conf test is successful



# Recharger
```
sudo systemctl reload nginx
```

- 5. Ouvrir le port 443 dans PFsense

> Firewall → Rules → LAN :
```
Règle 1 — accès HTTPS intranet LAN

Champ			Valeur
Action			Pass
Interface		LAN
Protocol		TCP
Source			LAN net (192.168.56.0/24)
Destination		192.168.100.30
Destination port	443 (HTTPS)
Description		LAN → Nginx HTTPS intranet
```

> Règle 2 — accès HTTPS intranet DMZ
```
Champ                   Valeur
Action                  Pass
Interface               LAN
Protocol                TCP
Source                  LAN net (192.168.56.0/24)
Destination             192.168.100.20
Destination port        443 (HTTPS)
Description   		LAN → Nginx HTTPS DMZ
```

> La règle 2 nécessite aussi une règle côté OPT1/DMZ pour que PFsense autorise le retour du trafic :
```
Champ                   Valeur
Action                  Pass  
Interface               OPT1 
Protocol                TCP
Source                  192.168.100.20
Destination             LAN net
Destination port        any
Description             DMZ Nginx → retour LAN




- 6. Faire confiance au certificat sur Win10-Client1
```
# Sur Win10-Client1, importer le certificat dans le magasin "Autorités racines de confiance"
# 1. Copier nginx.crt depuis Ubuntu vers le poste (via partage ou scp)
# 2. Double-clic sur le .crt → Installer le certificat
#    → Ordinateur local → Autorités de certification racines de confiance
```

> Ou via GPO depuis l'AD-Server pour déployer sur tous les postes du domaine (plus propre).

- 7. Format de log personnalisé (optionnel mais recommandé)
```
log_format  vhost_combined  '$host $remote_addr - $remote_user [$time_local] '
                             '"$request" $status $body_bytes_sent '
                             '"$http_referer" "$http_user_agent"';
```

> Puis dans chaque vhost, remplace access_log ... ; par :
```
access_log /var/log/nginx/intranet-lan-access.log vhost_combined;
```

