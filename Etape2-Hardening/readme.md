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

> Désactivez aussi l'interface d'administration PFsense depuis la DMZ : Interfaces → LAN uniquement pour l'accès WebGUI.


---
## Couche 2 — AD-Server (GPO)
---
- Ouvrez Group Policy Management sur l'AD-Server et créez une GPO Securite-Baseline liée au domaine monlabo.local.

```
# Politique de mots de passe
Computer Config → Windows Settings → Security Settings
  → Account Policies → Password Policy :
      Longueur minimale        : 12
      Complexité               : Activée
      Historique               : 10 mots de passe
      Durée maximale           : 90 jours

# Verrouillage de compte
  → Account Lockout Policy :
      Seuil                    : 5 tentatives
      Durée de verrouillage    : 30 minutes
      Réinitialisation         : 30 minutes

# Désactiver le compte invité
  → Local Policies → Security Options :
      Accounts: Guest account status → Disabled
```

- Activez aussi l'audit des connexions :
```
# Toujours dans la GPO
Computer Config → Windows Settings → Security Settings
  → Advanced Audit Policy :
      Logon/Logoff → Audit Logon : Success, Failure
      Account Management → Audit User Account Management : Success, Failure
```

---
## Couche 3 — Ubuntu / Nginx
---
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

