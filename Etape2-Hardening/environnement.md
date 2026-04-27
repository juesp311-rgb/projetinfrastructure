---
# Vérification de l'environnement
---

---
## Machine 1:Win10-Client ( Poste administrateur )
---

- Commandes exécutées

> Vérifie l'existence de la zone DNS monlabo.local sur le serveur 192.168.100.5
```
nslookup -type=SOA monlabo.local 192.168.100.5
```

> Vérifie l'enregistrement A pour intranet2.monlabo.local sur le serveur DNS 192.168.100.5
```
nslookup -type=A intranet2.monlabo.local 192.168.100.5
```

> Vérifie la résolution DNS pour intranet2.monlabo.local en utilisant le serveur DNS 192.168.100.5
```
Resolve-DnsName -Name intranet2.monlabo.local -Server 192.168.100.5
```

- Commandes supplémentaires

> Affiche la configuration IP détaillée de la machine
```
Get-NetIPConfiguration
```

> Vérifie la connectivité vers le site intranet2.monlabo.local sur le port 443 (HTTPS)
```
Test-NetConnection -ComputerName intranet2.monlabo.local -Port 443
```
> Vérifie la connectivité vers le serveur DNS sur le port 53
```
Test-NetConnection -ComputerName 192.168.100.5 -Port 53
```


---
## Machine 2: Serveur Active Directory (ad-server.monlabo.local)
---

> Adresse IP : 192.168.100.5
> Nom de domaine : monlabo.local
> Rôle : Serveur DNS pour la zone monlabo.local


- Commandes exécutées

> Vérifie l'existence de la zone DNS monlabo.local
```
Get-DnsServerZone -Name "monlabo.local"
```

> Vérifie l'enregistrement A pour intranet2.monlabo.local dans la zone monlabo.local
```
Get-DnsServerResourceRecord -Name "intranet2" -ZoneName "monlabo.local" -RRType A
```

> Crée la zone DNS monlabo.local (si elle n'existe pas)
```
Add-DnsServerPrimaryZone -Name "monlabo.local"
```

> Crée l'enregistrement A pour intranet2.monlabo.local (s'il n'existe pas)
``` Add-DnsServerResourceRecordA -Name "intranet2" -ZoneName "monlabo.local" -AllowUpdateAny -IPv4Address "192.168.100.10"
```


- Commandes supplémentaires
> Affiche les informations sur les contrôleurs de domaine découverts
```
Get-ADDomainController -Discover
```

> Liste tous les utilisateurs Active Directory
```
Get-ADUser -Filter *
```

> Liste tous les groupes Active Directory
```
Get-ADGroup -Filter *
```

> Affiche les redirecteurs DNS configurés
```
Get-DnsServerForwarder
```

> Affiche les diagnostics du serveur DNS
```
Get-DnsServerDiagnostics
```

---
## Machine 3: Serveur Web (SRV-WEB) 
---

> Adresse IP : 192.168.100.10
> Système d'exploitation : Microsoft Windows Server 2022 Standard Evaluation
> Rôle : Héberge le site web intranet2.monlabo.local


- Commandes exécutées

> Vérifie l'existence du site web intranet2.monlabo.local dans IIS
```
Get-Website -Name "intranet2.monlabo.local"
```

> Affiche les bindings (protocole, adresse IP, port) pour le site web intranet2.monlabo.local
```
Get-WebBinding -Name "intranet2.monlabo.local"
```

> Get-IISConfigSection`
```
`Get-ChildItem -Path "IIS:\Sites\intranet2.monlabo.local" -Recurse
```

- Commandes supplémentaires

> Where-Object {$_.InstallState -eq 'Installed'}`
```
`Get-WindowsFeature
```

> Liste tous les sites web configurés dans IIS
```
Get-IISSite
```

> Liste tous les application pools configurés dans IIS
```
Get-IISAppPool
```

> Affiche l'état de l'application pool pour le site intranet2.monlabo.local
```
Get-WebAppPoolState -Name "intranet2.monlabo.local"
```

> Affiche les paramètres d'authentification pour le site intranet2.monlabo.local
```
Get-WebConfigurationProperty -Filter system.webServer/security/authentication/* -PSPath "IIS:\Sites\intranet2.monlabo.local"
```

---
## Machine 4: Serveur Ubuntu avec Nginx
---

> Nom d'utilisateur : adminsys
> Rôle : Reverse proxy pour le site intranet2.monlabo.local


>Informations Nginx
>>Version de Nginx : 1.24.0
>>Version d'OpenSSL : 3.0.13
>>Fichier de configuration principal : /etc/nginx/nginx.conf
>>Fichier de configuration pour intranet2.monlabo.local : /etc/nginx/sites-available/intranet2.monlabo.local
>>Certificat SSL : /etc/nginx/ssl/nginx.crt (émis pour intranet2.monlabo.local, valide jusqu'au 25 avril 2027)
>>Clé privée SSL : /etc/nginx/ssl/nginx.key
>>Logs d'accès : /var/log/nginx/intranet-dmz-access.log
>>Logs d'erreur : /var/log/nginx/intranet-dmz-error.log



- Commandes exécutées

> Affiche le contenu du fichier de configuration Nginx principal
```
sudo cat /etc/nginx/nginx.conf
```

> Liste les fichiers de configuration disponibles pour les sites Nginx
```
sudo ls -l /etc/nginx/sites-available/
```

> Affiche le contenu du fichier de configuration pour le site intranet2.monlabo.local
```
sudo cat /etc/nginx/sites-available/intranet2.monlabo.local
```

> ssl_certificate_key' /etc/nginx/sites-available/intranet2.monlabo.local`
```
`sudo grep -E 'ssl_certificate
```

> Affiche l'émetteur et la date d'expiration du certificat SSL
```
sudo openssl x509 -in /etc/nginx/ssl/nginx.crt -noout -issuer -enddate
```

> Vérifie la présence d'en-têtes de sécurité dans la configuration du site
```
sudo grep -E 'add_header' /etc/nginx/sites-available/intranet2.monlabo.local
```

> Affiche la version de Nginx
```
nginx -v
```

> grep OpenSSL`
```
`nginx -V 2>&1
```

> grep 'configure arguments:'`
```
`nginx -V 2>&1
```

> error_log' /etc/nginx/nginx.conf`
```
`sudo grep -E 'access_log
```

> Vérifie la syntaxe des fichiers de configuration Nginx
```
sudo nginx -t
```

> Affiche le statut du service Nginx
```
sudo systemctl status nginx
```

- Commandes supplémentaires

> Affiche le statut du pare-feu UFW
```
sudo ufw status
```

> Affiche les ports en écoute et les services associés
```
sudo netstat -tuln
```

> Affiche la configuration Nginx complète avec les fichiers inclus
```
sudo nginx -T
```
> Affiche les détails du certificat SSL
```
sudo openssl x509 -in /etc/nginx/ssl/nginx.crt -text -noout
```
> Affiche les 50 dernières lignes du log d'accès
```
sudo tail -n 50 /var/log/nginx/intranet-dmz-access.log
```
> Affiche les 50 dernières lignes du log d'erreur
```
sudo tail -n 50 /var/log/nginx/intranet-dmz-error.log
```

> Recharge la configuration Nginx sans interrompre les connexions actives
```
sudo nginx -s reload
```

