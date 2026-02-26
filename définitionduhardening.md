🔐 Le Hardening, c’est quoi ?

Le hardening (ou durcissement de sécurité) consiste à réduire la surface d’attaque d’un système en supprimant tout ce qui est inutile et en sécurisant ce qui reste.

👉 Objectif : rendre un serveur beaucoup plus difficile à compromettre.

🧠 En version simple

Un serveur installé par défaut =
🚪 Beaucoup de portes ouvertes
🔓 Services inutiles actifs
🔑 Configurations permissives

Le hardening =
🔒 Fermer les portes inutiles
🧹 Nettoyer
🛡️ Restreindre les accès
📋 Mettre des règles strictes

💻 Exemple concret sur ton projet
1️⃣ Hardening SSH

Par défaut :

Root peut se connecter

Mot de passe autorisé

Port 22 visible

Hardening :

❌ Désactiver root login

🔑 Authentification par clé uniquement

🔄 Changer le port

⏳ Limiter les tentatives

2️⃣ Hardening réseau

Activer firewall (UFW / firewalld)

Autoriser uniquement :

Ubuntu Web → port 80

CentOS DB → port 3306 depuis Ubuntu seulement

Bloquer tout le reste

3️⃣ Hardening services

Supprimer services inutiles

Désactiver IPv6 si non utilisé

Désactiver modules Apache inutiles

Masquer version serveur (nginx/apache)

4️⃣ Hardening système

Mises à jour automatiques

Fail2ban

Auditd

Logs centralisés

Permissions strictes sur fichiers sensibles

🎯 Pourquoi c’est important ?

Parce que :

80% des attaques exploitent des configs par défaut

Un serveur exposé sans hardening = compromis en quelques minutes

En entretien DevOps/Sysadmin, c’est une question quasi obligatoire

🏢 En entreprise

On suit souvent des guides comme :

CIS Benchmarks

ANSSI (en France)

NIST

ISO 27001

🧩 Dans TON projet

Le hardening est ce qui va transformer ton lab de :

"VMs qui fonctionnent"

en

"Infrastructure qui ressemble à une prod réelle"

Si tu veux, on peut faire :

🔥 Un hardening complet pas-à-pas sur ton Ubuntu Web

🔥 Ou commencer par sécuriser ta base CentOS correctement
