# Résolution — Remise en place du serveur HTTPS `intranet2.monlabo.local`

## Architecture de l'environnement

```
[Win10-Client1] 192.168.100.50
      |
      | Réseau interne VirtualBox "DMZ" — 192.168.100.0/24
      |
[AD-Server] Ethernet 3 — 192.168.100.5      ← DNS + DHCP
[PFsense OPT1] — 192.168.100.2              ← Gateway
[UbuntuServer/Nginx] — 192.168.100.20       ← Reverse proxy HTTPS
[SRV-Web/IIS] — 192.168.100.10             ← Backend web
```

---

## Problème initial

La connexion à `https://intranet2.monlabo.local` était perdue après une reconfiguration de l'AD-Server sur le réseau DMZ.

---

## Étape 1 — Configuration de l'AD-Server (DNS + DHCP pour la DMZ)

### 1.1 Corriger le DNS sur Ethernet 3

L'interface Ethernet 3 de l'AD-Server pointait vers des serveurs DNS IPv6 fantômes (`fec0:0:0:ffff::1`). Il faut la faire pointer vers elle-même :

```powershell
Set-DnsClientServerAddress `
    -InterfaceAlias "Ethernet 3" `
    -ServerAddresses 127.0.0.1
```

### 1.2 Créer le scope DHCP pour la DMZ

```powershell
Add-DhcpServerv4Scope `
    -Name "DMZ" `
    -StartRange "192.168.100.50" `
    -EndRange "192.168.100.150" `
    -SubnetMask "255.255.255.0" `
    -State Active

Set-DhcpServerv4OptionValue `
    -ScopeId "192.168.100.0" `
    -DnsServer 192.168.100.5 `
    -Router 192.168.100.2 `
    -DnsDomain "monlabo.local"

Add-DhcpServerv4ExclusionRange `
    -ScopeId "192.168.100.0" `
    -StartRange "192.168.100.1" `
    -EndRange "192.168.100.49"
```

### 1.3 Créer l'enregistrement DNS pour intranet2

```powershell
Add-DnsServerResourceRecordA `
    -ZoneName "monlabo.local" `
    -Name "intranet2" `
    -IPv4Address "192.168.100.20"
```

Vérification :
```powershell
Get-DnsServerResourceRecord -ZoneName "monlabo.local" -Name "intranet2"
```

---

## Étape 2 — Configuration de Win10-Client1

Win10-Client1 était non configuré. Il faut s'assurer qu'il est sur le réseau interne **DMZ** dans VirtualBox, puis renouveler le bail DHCP :

```cmd
ipconfig /release
ipconfig /renew
ipconfig /all
```

Résultat attendu :
- IP : `192.168.100.50` à `192.168.100.150`
- DNS : `192.168.100.5`
- Gateway : `192.168.100.2`

Test de résolution DNS :
```cmd
nslookup intranet2.monlabo.local
```

Résultat attendu :
```
Serveur : AD-Server.monlabo.local
Address : 192.168.100.5
Nom     : intranet2.monlabo.local
Address : 192.168.100.20
```

---

## Étape 3 — Vérification de Nginx (UbuntuServer)

### Configuration Nginx existante

```nginx
# /etc/nginx/sites-available/intranet2

server {
    listen 8080;
    server_name intranet2.monlabo.local;
    return 301 https://$host:8443$request_uri;
}

server {
    listen 8443 ssl;
    server_name intranet2.monlabo.local;
    ssl_certificate     /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_ciphers         HIGH:!aNULL:!MD5;

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

### Vérifications Nginx

```bash
sudo nginx -t
sudo systemctl status nginx
sudo ss -tlnp | grep nginx
```

Nginx doit écouter sur les ports **8080** et **8443**.

---

## Étape 4 — Résolution du certificat SSL auto-signé

### 4.1 Recréer le certificat avec SAN (Subject Alternative Name)

Les navigateurs modernes exigent un champ SAN pour valider un certificat. Sans lui, le cadenas reste rouge.

```bash
sudo openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=intranet2.monlabo.local" \
    -addext "subjectAltName=DNS:intranet2.monlabo.local,IP:192.168.100.20"

sudo systemctl reload nginx
```

Vérification du SAN :
```bash
openssl x509 -in /etc/nginx/ssl/nginx.crt -noout -text | grep -A 3 "Subject Alternative"
```

Résultat attendu :
```
X509v3 Subject Alternative Name:
    DNS:intranet2.monlabo.local, IP Address:192.168.100.20
```

### 4.2 Importer le certificat dans Windows (Win10-Client1)

Copier le contenu de `/etc/nginx/ssl/nginx.crt` dans un fichier `nginx.crt` sur le bureau de Win10-Client1, puis en PowerShell admin :

```powershell
Import-Certificate -FilePath "C:\Users\jdupont\Desktop\nginx.crt" `
    -CertStoreLocation "Cert:\LocalMachine\Root"
```

Vérification :
```powershell
Get-ChildItem "Cert:\LocalMachine\Root" | `
    Sort-Object NotBefore -Descending | `
    Select-Object -First 5 Subject, Thumbprint, NotBefore
```

---

## Étape 5 — Résolution du problème SRV-Web (IIS)

### 5.1 Problèmes identifiés

| Problème | Cause |
|---|---|
| SRV-Web injoignable depuis Ubuntu | Mauvaise route réseau sur Ethernet 3 |
| Port 80 bloqué | Firewall Windows `BlockInbound` |
| Binding IIS incorrect | IIS écoutait uniquement sur `192.168.56.20` |
| Conflit de binding | `intranet2.monlabo.local` dupliqué sur deux sites IIS |

### 5.2 Corriger la route réseau sur SRV-Web

```powershell
# Supprimer la mauvaise route (SRV-Web se routait vers lui-même)
Remove-NetRoute -InterfaceAlias "Ethernet 3" `
    -DestinationPrefix "192.168.100.0/24" `
    -NextHop "192.168.100.10" -Confirm:$false

# Reconfigurer l'IP proprement (recrée la route locale automatiquement)
Remove-NetIPAddress -InterfaceAlias "Ethernet 3" `
    -IPAddress "192.168.100.10" -Confirm:$false

New-NetIPAddress `
    -InterfaceAlias "Ethernet 3" `
    -IPAddress "192.168.100.10" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.100.2"
```

### 5.3 Ouvrir le port 80 dans le firewall Windows

```powershell
New-NetFirewallRule `
    -DisplayName "HTTP Inbound DMZ" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 80 `
    -Action Allow `
    -Profile Any
```

### 5.4 Corriger les bindings IIS

```powershell
# Supprimer le binding dupliqué sur Default Web Site
Remove-WebBinding -Name "Default Web Site" `
    -Protocol http -Port 80 -IPAddress "192.168.100.10" `
    -HostHeader "intranet2.monlabo.local"

# S'assurer que le binding est sur le bon site
New-WebBinding -Name "intranet2" `
    -Protocol http `
    -Port 80 `
    -IPAddress "192.168.100.10" `
    -HostHeader "intranet2.monlabo.local"

# Démarrer les sites
Start-Website -Name "Default Web Site"
Start-Website -Name "intranet2"

# Vérifier
Get-Website
```

---

## Étape 6 — Test final

### Depuis Ubuntu
```bash
curl -v -H "Host: intranet2.monlabo.local" http://192.168.100.10
```

### Depuis Win10-Client1 (navigateur Edge)
```
http://intranet2.monlabo.local:8080
```
→ Redirige automatiquement vers `https://intranet2.monlabo.local:8443`

---

## Récapitulatif des causes racines

| Cause | Solution appliquée |
|---|---|
| Win10-Client1 sans IP ni DNS | DHCP + DNS configurés via AD-Server |
| DNS `intranet2` manquant dans l'AD | Enregistrement A ajouté dans la zone `monlabo.local` |
| Mauvaise route sur SRV-Web | Reconfiguration IP + suppression route incorrecte |
| Firewall Windows bloquait port 80 | Règle `Allow Inbound TCP 80` ajoutée |
| Binding IIS dupliqué | Nettoyage et recréation propre des bindings |
| Certificat SSL sans SAN | Recréation avec `-addext subjectAltName` |
| Certificat non reconnu par Edge | Import dans `Cert:\LocalMachine\Root` |

---

## Schéma du flux final fonctionnel

```
[Win10-Client1]
      |
      | 1. http://intranet2.monlabo.local:8080
      ↓
[Nginx :8080] → redirect 301 → https://:8443
      |
      | 2. https://intranet2.monlabo.local:8443 (SSL/TLS)
      ↓
[Nginx :8443] → proxy_pass → http://192.168.100.10:80
      |
      | 3. http://192.168.100.10:80
      ↓
[IIS SRV-Web] → répond avec le contenu du site intranet2
```
