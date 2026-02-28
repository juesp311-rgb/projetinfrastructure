# Projet : “Mini-Infrastructure d’Entreprise On-Prem / Cloud”

## L’objectif était de simuler une vraie infra d’entreprise, avec contraintes de production.


### 🏗️ 1. Architecture

Mettre en place :

> 1 reverse proxy (Nginx ou Traefik)
>
> 1 cluster Kubernetes (k3s ou kubeadm)
>
>1 registry privée
>
>1 serveur de monitoring
>
> 1 serveur de logs centralisés
>
> 1 pipeline CI/CD complet

Le tout :

* soit en homelab (Proxmox / VMs)

* soit sur cloud (AWS / Hetzner / OVH) avec Terraform

### 📦2. Partie Systèmes

Ce que tu devais implémenter :

> Hardening Linux (SSH, fail2ban, firewall, audit)
>
> Gestion utilisateurs / groupes / permissions
>
> Sauvegardes automatiques chiffrées
>
> Rotation de logs
>
> Certificats TLS automatiques (Let's Encrypt)
>
> Gestion des secrets


### ☸️ 3. Partie Kubernetes

Déploiement d’une app multi-tiers :

> Frontend
>
> API
>
> Base de données
>
> Ingress + TLS
>
> Autoscaling
>
> Liveness / readiness probes
>
> Network policies
>
> Helm chart maison


### 📊4. Observabilité

>Metrics (Prometheus + Grafana)
>
>Logs centralisés (Loki / ELK)
>
>Alerting (Alertmanager)
>
>Dashboard “Production”




### 🚀5. CI/CD

> Pipeline :
>
>> Build image
>
>> Scan sécurité
>
>> Push registry
>
>> Déploiement auto sur cluster
>
>> Rollback automatique si échec


**Bonus :**

- GitOps (ArgoCD ou Flux)

### 🔐6. Bonus “Senior Level”

> Haute dispo (multi-node)
>
>Load balancer
>
>Disaster Recovery plan documenté
>
>Monitoring des coûts (si cloud)
>
>Chaos testing simple

### 🎯Objectif du projet

Avoir :

* Une infra documentée
* Des diagrammes d’architecture
* Un README type “runbook production”
* Un repo Git propre montrable en entretien



Configuration réseau Interne

- 1 réseau NAT (internet)
- 1 réseau Internal Network (communication entre vm)
- 1 reséau host-only : (ssh)


> VM  UbuntuServer 
>
>>Interface enp0s8
>
>> Ip : 192.168.10.10
>
>> NIC2 :  attachée à Internal Network


## 🎯 Objectif Phase 1 : Transformer tes 3 VMs en mini SI d’entreprise

### ÉTAPE 1 — Architecture réseau propre

#### Configuration réseau Interne

- 1 réseau NAT (internet)
- 1 réseau Internal Network (communication entre vm)
- 1 reséau host-only : (ssh)


### 🔐 ÉTAPE 2 — Hardening minimal obligatoire

Sur Ubuntu + CentOS :

✔️ Mise à jour complète

```bash
sudo apt update && sudo apt upgrade -y
# ou
sudo dnf update -y
'''

✔️ Création d’un user admin
```bash
sudo adduser adminsys
sudo usermod -aG sudo adminsys
```

✔️ Désactiver root SSH

Modifier

```bash
nano /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no (si clé SSH)
```

✔️ Firewall

Ubuntu :

```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw enable
```

CentOS :
```bash 
sudo firewall-cmd --permanent --add-service=mysql
sudo firewall-cmd --reload
```

### 🌐 ÉTAPE 3 — Mise en place Web + DB

🗄️ Sur CentOS (DB)

Installer MariaDB :

```bash
sudo dnf install mariadb-server -y
sudo systemctl enable --now mariadb
```

Sécuriser : 

```bash
sudo mysql_secure_installation
```
Créer :

Une base entreprise

Un user appuser accessible uniquement depuis IP Ubuntu


🌍 Sur Ubuntu (Web)

Installer Nginx + PHP :

```bash
sudo apt install nginx php-fpm php-mysql -y
```

Créer une petite app PHP :

```bash
<?php
$conn = new mysqli("192.168.56.20", "appuser", "password", "entreprise");
if ($conn->connect_error) die("DB failed");
echo "Connexion OK";
?>
```

Test depuis Windows → navigateur → IP Ubuntu

🎉 Si ça marche : architecture 3-tiers validée.


### 🖥️ ÉTAPE 4 — Windows Server (Client d’Entreprise)

Sur Windows :

* Installer RSAT
* Installer navigateur
* Tester accès web
* Installer Putty ou OpenSSH pour accès admin

Bonus :

* Joindre Ubuntu au domaine si tu veux simuler AD
* Mettre en place partage SMB


### 📊 ÉTAPE 5 — Monitoring (niveau supérieur)

Sur Ubuntu :

Installer :

* Prometheus
* Grafana

Ou plus simple pour commencer :

* Netdata

Objectif : monitorer CPU, RAM, DB, HTTP.



### 💾 ÉTAPE 6 — Sauvegardes

Sur CentOS :

Script bash :

```bash
mysqldump entreprise > /backup/entreprise_$(date +%F).sql
```

Cron job

Sur Ubuntu :

Backup des configs Nginx + app




** 🔥 Maintenant on passe au niveau “pro” **

Après ça, on pourra ajouter :

* Reverse proxy
* TLS (Let's Encrypt)
* Centralisation logs
* Dockerisation

* Puis Kubernetes

** 🎯 Question importante **

Tu veux faire :

A) Version pure sysadmin classique (Linux + Windows + services)
B) Version orientée DevOps (Docker + CI/CD)
C) Version SRE / monitoring avancé
D) Full parcours progressif étape par étape

Dis-moi ton objectif final (emploi ? montée en compétence cloud ? freelance ?), et je te fais un plan structuré sur 4–6 semaines.
