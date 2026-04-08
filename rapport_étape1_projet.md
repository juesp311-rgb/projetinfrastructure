---
## 📄Rapport étape 1 du projet : Mini infrastructure d'une SI.
---


---
** 🧾 1. Introduction **
---

Dans le cadre de ma formation, j’ai mis en place une infrastructure réseau sécurisée comprenant un pare-feu pfSense, un serveur Active Directory, un serveur Web et un poste client.
L’objectif est de simuler une architecture d’entreprise en assurant la sécurité, la gestion des utilisateurs et l’accès à un service web.

---
** 🎯 2. Objectifs du projet **
---

	- Mettre en place un pare-feu pfSense
	- Déployer un domaine Active Directory
	- Installer un serveur Web accessible depuis Internet
	- Sécuriser l’architecture avec une DMZ
	- Permettre l’accès depuis un poste client

---
** 🧱 3. Architecture réseau **
---

- L’infrastructure est composée de trois zones :

	- WAN : accès Internet
	- DMZ : hébergement du serveur web (en cours)
	- LAN : réseau interne (AD + client + serveur web)

> le LAN héberge le serveur = problème de sécurité

- Éléments :
	- pfSense : routeur / firewall
	- Serveur AD : gestion des utilisateurs
	- Serveur Web : service public
	- Client Windows : poste utilisateur


![Schéma réseau](https://github.com/juesp311-rgb/projetinfrastructure/blob/main/imageProjet/ADServer_PFsense_WebServer_WinClien.png)

*Figure 1 : Architecture réseau*


---
** ⚙️ 4. Mise en place technique **
---

- 🔥 4.1 Configuration de pfSense
	- Interfaces configurées :
		- WAN
		- LAN
		- DMZ

	- Règles firewall :
		- Autorisation HTTP/HTTPS vers serveur web
		- Blocage accès direct LAN depuis WAN
		- NAT configuré :


	- Redirection port 80 → serveur web

- 🖥️ 4.2 Installation Active Directory
	- Installation de Windows Server
	- Ajout du rôle AD DS
	- Création du domaine (ex : entreprise.local)
	- Création :
		- utilisateurs
		- groupes

	- Configuration DNS


- 🌐 4.3 Serveur Web
	- Installation (Apache / IIS)
	- Déploiement d’un site web
	- Placement en DMZ
	- Test accès depuis Internet

- 💻 4.4 Poste client
	- Installation Windows
	- Intégration au domaine
	- Test :
		- connexion utilisateur AD
		- accès au site web

- 🔐 5. Sécurité mise en place
	- Isolation DMZ / LAN
	- Filtrage via pfSense
	- Authentification centralisée (AD)
	- Ports ouverts limités :
		- 80 / 443 uniquement

- 🧪 6. Tests réalisés


	- ✅ Accès au site web depuis Internet
	- ✅ Connexion au domaine
	- ✅ Blocage accès direct au LAN
	- ✅ Résolution DNS fonctionnelle

- ⚠️ 7. Problèmes rencontrés


- Mauvaise configuration Ip Statique
- Ping  bloqué par firewall
- Conflit IP AD-Server et PFsenseClient 



- 👉 Résolu :

- IP “statique via DHCP” (réservation DHCP) ✅
> L’IP est toujours la même, mais attribuée automatiquement

- Commande NetFirewallRule

- 📈 8. Améliorations possibles
	- Mise en place d'une DMZ
	- Ajout HTTPS (certificat SSL)
	- Mise en place VPN
	- Surveillance (Zabbix, Grafana)
	- Sauvegardes automatisées

🧾 9. Conclusion

Ce projet m’a permis de comprendre le fonctionnement d’une infrastructure réseau sécurisée, notamment l’utilisation d’un pare-feu, la gestion d’un domaine Active Directory et la mise en place d’une DMZ.
Il constitue une base solide pour des environnements professionnels.
