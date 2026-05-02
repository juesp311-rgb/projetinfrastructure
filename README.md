# 📱 MobileLab — Documentation Complète

## Homelab Mobile : Termux + Tailscale + Kaido

---

## 📋 Table des matières

1. Architecture du projet
2. Connexion Tailscale
3. Services déployés
4. Kaido Web (Chat IA)
5. Kaido Discord (Bot)
6. Kaido Monitor (Dashboard)
7. Kaido Notify (Notifications)
8. Kaido Scan (Audit réseau)
9. PostgreSQL
10. Commandes réseau Termux
11. Commandes Kali (scan avancé)
12. Gestion des services
13. Cloudflare Tunnel
14. Dépannage

---

## 1. Architecture du projet

```
┌─────────────────────────────────────────────┐
│              RÉSEAU TAILSCALE               │
│                                             │
│  📱 Redmi Note 14        💻 Kali Linux      │
│  100.83.233.61           100.116.145.4      │
│                                             │
│  ┌─ Kaido Web    :8080   ┌─ SSH       :22   │
│  ├─ Kaido Notify :9090   └─ nmap, tcpdump   │
│  ├─ Kaido Monitor:9091                      │
│  ├─ SSH Termux   :8022                      │
│  ├─ PostgreSQL   :5432                      │
│  └─ Kaido Discord (bot)                     │
│                                             │
└─────────────────────────────────────────────┘
```

### Arborescence des fichiers

```
~/go/
├── kaido-web/           # Chat IA (Go + PostgreSQL)
│   ├── main.go
│   ├── go.mod
│   ├── go.sum
│   ├── sql/
│   │   └── schema.sql
│   └── public/
│       ├── index.html
│       ├── css/style.css
│       └── js/app.js
│
├── kaido-monitor/       # Dashboard temps réel
│   └── main.go
│
├── kaido-notify/        # Notifications multi-appareils
│   └── main.go
│
├── kaido-scan/          # Audit réseau & sécurité
│   └── main.go
│
└── kaido-go/            # Bot Discord (Go)
    └── main.go

~/discord_bot.py          # Bot Discord (Python, v2)
~/notif_kali.py           # Notifications Kali (Python)
```

---

## 2. Connexion Tailscale

Tailscale crée un VPN mesh entre tes appareils. Chaque appareil reçoit une IP fixe en `100.x.x.x`.

### Tes appareils

| Appareil | IP Tailscale | OS |
|----------|-------------|-----|
| Redmi Note 14 | 100.83.233.61 | Android |
| PC Kali | 100.116.145.4 | Linux |

### Sur Kali (installer)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo systemctl enable --now tailscaled
sudo tailscale up
```

### Sur Android

Installer l'app **Tailscale** depuis le Play Store, activer la connexion.

> ⚠️ Tailscale sur Termux n'est pas en CLI, il fonctionne via l'app Android.

```bash
~/go $ tailscale status
```
> Résultat (depuis Termux) :
```
No command tailscale found
```
> Normal — utiliser l'app Android à la place.

### Vérifier la connexion (depuis Kali)

```bash
tailscale status
```
> Résultat :
```
100.116.145.4  kali           juesp311@  linux    -
100.83.233.61  redmi-note-14  juesp311@  android  active; direct
```

### Se connecter au téléphone depuis Kali

```bash
ssh juesp311@100.83.233.61 -p 8022
```

> ⚠️ Termux utilise le port **8022** (pas le port 22 standard).

### Se connecter au Kali depuis Termux

```bash
ssh jukali@100.116.145.4
```

### Transférer un fichier (Kali → Termux)

```bash
scp -P 8022 ~/mon_fichier.py juesp311@100.83.233.61:~/
```

### Transférer un fichier (Termux → Kali)

```bash
scp mon_fichier.py jukali@100.116.145.4:~/
```

---

## 3. Services déployés

| Service | Port | Langage | Accès local | Accès Tailscale |
|---------|------|---------|-------------|-----------------|
| Kaido Web | 8080 | Go | localhost:8080 | 100.83.233.61:8080 |
| Kaido Notify | 9090 | Go | localhost:9090 | 100.83.233.61:9090 |
| Kaido Monitor | 9091 | Go | localhost:9091 | 100.83.233.61:9091 |
| PostgreSQL | 5432 | — | localhost:5432 | — |
| SSH Termux | 8022 | — | — | 100.83.233.61:8022 |
| Kaido Discord | — | Go/Python | — | — |

### Vérifier les services

```bash
ps aux | grep kaido
```
> Résultat :
```
./kaido-web    (PID xxxxx)
./kaido-notify (PID xxxxx)
./kaido-monitor(PID xxxxx)
postgres: kaido kaido_db ...
```

---

## 4. Kaido Web (Chat IA)

Interface web de chat connectée à **Mistral AI** (gratuit).

### Stack

- Backend : Go (API REST)
- Frontend : HTML/CSS/JS
- Base de données : PostgreSQL
- IA : Mistral API (gratuit)

### URL

```
http://100.83.233.61:8080
```

### API Endpoints

| Méthode | URL | Description |
|---------|-----|-------------|
| GET | /api/conversations | Liste des conversations |
| POST | /api/conversations | Nouvelle conversation |
| DELETE | /api/conversations?id=X | Supprimer une conversation |
| GET | /api/messages?conversation_id=X | Messages d'une conversation |
| POST | /api/send | Envoyer un message (+ réponse IA) |
| GET | /api/cron | Liste des cron jobs |
| POST | /api/cron | Créer un cron job |
| PUT | /api/cron | Toggle actif/inactif |
| DELETE | /api/cron?id=X | Supprimer un cron job |
| GET | /api/settings | Paramètres |
| POST | /api/settings | Modifier un paramètre |

### Tester l'API

```bash
# Liste des conversations
curl -s http://localhost:8080/api/conversations

# Paramètres
curl -s http://localhost:8080/api/settings
```

### Fonctionnalités

- Chat avec Mistral AI (historique sauvegardé en PostgreSQL)
- Cron jobs (messages planifiés, avec option IA)
- 4 thèmes : Sombre, Clair, Hacker, Océan
- Choix du modèle IA (Mistral Large, Small, Codestral)
- Personnalité customisable

### Lancer

```bash
cd ~/go/kaido-web
./kaido-web
```

### Lancer en arrière-plan

```bash
nohup ./kaido-web > kaido-web.log 2>&1 &
```

---

## 5. Kaido Discord (Bot)

Bot Discord connecté à Mistral AI.

### Commandes Discord

| Commande | Description |
|----------|-------------|
| `!ask <question>` | Poser une question à l'IA |
| `@Kaido <question>` | Mentionner le bot |
| `!clear` | Réinitialiser l'historique |
| `!model` | Modèle IA utilisé |
| `!cron list` | Voir les jobs planifiés |
| `!cron add HH:MM <msg>` | Ajouter un job quotidien |
| `!cron add HH:MM ai:<prompt>` | Job IA quotidien |
| `!cron remove <id>` | Supprimer un job |
| `!rappel <min> <msg>` | Rappel dans X minutes |
| `!meteo <ville>` | Météo actuelle |
| `!ping` | Latence |
| `!uptime` | Temps de fonctionnement |
| `!info` | Infos serveur |
| `!help` | Aide |

### Version Go

```bash
cd ~/go/kaido-go
./kaido
```

### Version Python

```bash
cd ~
python discord_bot.py
```

### Lancer en arrière-plan

```bash
cd ~/go/kaido-go
nohup ./kaido > kaido.log 2>&1 &
```

---

## 6. Kaido Monitor (Dashboard)

Dashboard temps réel : CPU, RAM, disque, batterie, réseau.

### URL

```
http://100.83.233.61:9091
```

### API

```bash
# Stats en JSON
curl -s http://localhost:9091/api/stats
```
> Résultat :
```json
{
  "hostname": "localhost",
  "os": "android",
  "arch": "arm64",
  "cpu_usage": 2.3,
  "mem_total": 7655,
  "mem_used": 4225,
  "battery": 90,
  "batt_status": "DISCHARGING",
  "temperature": 26.0
}
```

### Fonctionnalités

- CPU, RAM, Disque, Batterie en temps réel
- Rafraîchissement automatique (3 secondes)
- Envoi de notifications (toast Termux + popup Kali)
- Indicateur LIVE

### Notifications

Depuis l'interface web ou en CLI :

```bash
termux-toast "Mon message"
```

> ⚠️ `termux-notification` ne fonctionne pas avec le Termux du Play Store. Utiliser `termux-toast` à la place.

```bash
termux-toast "Test popup"
```
> Résultat : popup apparaît sur le téléphone ✅

```bash
termux-notification --title "Test" --content "Hello"
```
> Résultat :
```
Termux:API is not yet available on Google Play
```
> ❌ Non supporté avec Termux Play Store.

### Lancer

```bash
cd ~/go/kaido-monitor
./kaido-monitor
```

---

## 7. Kaido Notify (Notifications)

Envoyer des notifications à tous tes appareils.

### URL

```
http://100.83.233.61:9090
```

### Commandes CLI

```bash
cd ~/go/kaido-notify

# Voir les machines
./kaido-notify list

# Envoyer un message
./kaido-notify send "Salut depuis Termux !"

# Avec un titre
./kaido-notify send "🔔 Alerte" "Le backup est terminé"

# Test
./kaido-notify test

# Lancer le serveur web
./kaido-notify server
```

---

## 8. Kaido Scan (Audit réseau)

Scanner le réseau et auditer la sécurité.

### Commandes

```bash
cd ~/go/kaido-scan

# Audit complet
./kaido-scan all

# Adresses IP
./kaido-scan ip

# Scanner les ports locaux
./kaido-scan ports

# Scanner les ports d'une machine
./kaido-scan ports 100.116.145.4

# Vérifier les services
./kaido-scan services

# Test DNS
./kaido-scan dns

# Ping
./kaido-scan ping google.com

# Infos réseau
./kaido-scan net

# Audit sécurité
./kaido-scan sec
```

### Exemple : audit complet

```bash
./kaido-scan all
```
> Résultat :
```
⚡ SERVICES ACTIFS
   ✅ Kaido Web (127.0.0.1:8080) — UP
   ✅ Kaido Notify (127.0.0.1:9090) — UP
   ✅ PostgreSQL (127.0.0.1:5432) — UP
   ✅ SSH Termux (127.0.0.1:8022) — UP

⚡ SCAN PORTS — 127.0.0.1
   5 port(s) ouvert(s) :
   ✅ Port 53 (DNS) — OUVERT
   ✅ Port 9090 (Kaido-Notify) — OUVERT
   ✅ Port 8022 (SSH-Termux) — OUVERT
   ✅ Port 8080 (HTTP-Alt) — OUVERT
   ✅ Port 5432 (PostgreSQL) — OUVERT

⚡ TEST DNS
   ✅ google.com → 142.251.209.142 (49ms)
   ✅ github.com → 140.82.121.4 (52ms)
   ✅ api.mistral.ai → 172.66.2.203 (57ms)

⚡ AUDIT SÉCURITÉ
   ✅ Aucun port dangereux ouvert
   ✅ SSH Termux actif (port 8022)
```

---

## 9. PostgreSQL

### Commandes de base

```bash
# Démarrer PostgreSQL
pg_ctl -D $PREFIX/var/lib/postgresql start

# Arrêter PostgreSQL
pg_ctl -D $PREFIX/var/lib/postgresql stop

# Se connecter
psql -d kaido_db

# Voir les conversations
psql -d kaido_db -c "SELECT * FROM conversations;"

# Voir les messages
psql -d kaido_db -c "SELECT * FROM messages ORDER BY created_at DESC LIMIT 10;"

# Voir les cron jobs
psql -d kaido_db -c "SELECT * FROM cron_jobs;"

# Voir les paramètres
psql -d kaido_db -c "SELECT * FROM settings;"

# Compter les messages
psql -d kaido_db -c "SELECT COUNT(*) FROM messages;"
```

### Supprimer les données (chat éphémère)

```bash
psql -d kaido_db -c "DELETE FROM messages;"
psql -d kaido_db -c "DELETE FROM conversations;"
```

### Supprimer toute la base

```bash
dropdb kaido_db
```

### Recréer la base

```bash
createdb -O kaido kaido_db
psql -d kaido_db -f ~/go/kaido-web/sql/schema.sql
```

---

## 10. Commandes réseau Termux

> ⚠️ Termux sans root a des limitations. Certaines commandes sont restreintes.

### Ce qui fonctionne

```bash
# Interfaces réseau
ifconfig
```
> Résultat :
```
ap0:    inet 10.94.235.196    (WiFi/Hotspot)
ccmni1: inet 10.31.128.251   (Données mobiles)
lo:     inet 127.0.0.1       (Loopback)
tun0:   inet 100.83.233.61   (Tailscale VPN)
```

```bash
# Ping
ping -c 3 google.com

# DNS
cat /etc/resolv.conf

# Routes
ip route show
```

### Ce qui ne fonctionne PAS (sans root)

```bash
ss -tuln
```
> Résultat :
```
Cannot open netlink socket: Permission denied
```

```bash
cat /proc/net/tcp
```
> Résultat :
```
cat: /proc/net/tcp: Permission denied
```

```bash
termux-wifi-connectioninfo
```
> Résultat :
```
Termux:API is not yet available on Google Play
```

### Alternative : utiliser kaido-scan

```bash
~/go/kaido-scan/kaido-scan services
~/go/kaido-scan/kaido-scan ports
~/go/kaido-scan/kaido-scan sec
```

---

## 11. Commandes Kali (scan avancé)

Ton Kali a accès complet à tous les outils réseau.

### Scanner le réseau

```bash
# Découvrir les appareils
sudo nmap -sn 192.168.1.0/24

# Scanner ton téléphone via Tailscale
nmap -sV 100.83.233.61

# Scanner les deux machines Tailscale
nmap -sV 100.83.233.61 100.116.145.4

# Scan ciblé des ports Kaido
nmap -sV -p 8022,8080,9090,9091,5432 100.83.233.61
```

> Résultat du scan Tailscale :
```
Redmi (100.83.233.61):
  8022/tcp  SSH      OpenSSH 10.3
  8080/tcp  HTTP     Golang (Kaido Web)
  9090/tcp  HTTP     Golang (Kaido Notify)

Kali (100.116.145.4):
  22/tcp    SSH      OpenSSH 10.2 Debian
```

### Analyser le trafic

```bash
# Capturer le trafic
sudo tcpdump -i any -c 50

# Trafic Tailscale
sudo tcpdump -i tailscale0 -c 20

# Wireshark
sudo wireshark
```

### Vérifier les connexions

```bash
ss -tuln
netstat -tlnp
```

---

## 12. Gestion des services

### Tout démarrer

```bash
# PostgreSQL
pg_ctl -D $PREFIX/var/lib/postgresql start

# Kaido Web
cd ~/go/kaido-web && nohup ./kaido-web > kaido-web.log 2>&1 &

# Kaido Notify
cd ~/go/kaido-notify && nohup ./kaido-notify server > notify.log 2>&1 &

# Kaido Monitor
cd ~/go/kaido-monitor && nohup ./kaido-monitor > monitor.log 2>&1 &

# Kaido Discord
cd ~/go/kaido-go && nohup ./kaido > kaido.log 2>&1 &
```

### Tout vérifier

```bash
ps aux | grep kaido
```

### Tout arrêter

```bash
pkill -f kaido-web
pkill -f kaido-notify
pkill -f kaido-monitor
pkill -f kaido-go
pg_ctl -D $PREFIX/var/lib/postgresql stop
```

### Voir les logs

```bash
cat ~/go/kaido-web/kaido-web.log
cat ~/go/kaido-notify/notify.log
cat ~/go/kaido-monitor/monitor.log
cat ~/go/kaido-go/kaido.log
```

---

## 13. Cloudflare Tunnel

Rendre un service accessible depuis internet (lien temporaire).

### Installer

```bash
pkg install cloudflared
```

### Créer un tunnel

```bash
cloudflared tunnel --url http://localhost:8080
```
> Résultat :
```
Your quick Tunnel has been created!
https://agriculture-hair-folding-gnu.trycloudflare.com
```

Partage ce lien — accessible depuis n'importe où dans le monde.

### Arrêter

**Ctrl+C** — le lien est mort instantanément.

### Relancer

```bash
cloudflared tunnel --url http://localhost:8080
```

> Génère un nouveau lien à chaque fois.

---

## 14. Dépannage

### "Connection refused" sur SSH

```bash
# Lancer sshd dans Termux
sshd
```

### PostgreSQL ne démarre pas

```bash
pg_ctl -D $PREFIX/var/lib/postgresql -l ~/pg.log start
cat ~/pg.log
```

### Token Discord invalide

1. discord.com/developers → Bot → Reset Token
2. Mettre à jour dans le fichier main.go
3. Recompiler : `go build -o kaido`

### Clé Mistral invalide

1. console.mistral.ai → API Keys → Créer nouvelle clé
2. Mettre à jour dans Kaido Web → Paramètres

### Service ne répond pas

```bash
# Vérifier s'il tourne
ps aux | grep kaido

# Relancer
cd ~/go/kaido-web && ./kaido-web
```

### Tailscale déconnecté

Ouvrir l'app Tailscale sur Android et activer la connexion.

---

*MobileLab — Mai 2026*
*Termux + Tailscale + Go + PostgreSQL + Mistral AI*
