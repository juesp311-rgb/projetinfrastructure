---
## 📄Rapport étape 1 du projet : Mini infrastructure d'une SI.
---


---
** 🧾 1. Introduction **
---

Dans le cadre de ma formation, j’ai mis en place une infrastructure réseau sécurisée comprenant un pare-feu pfSense, un serveur Active Directory, un serveur Web et un poste client.
L’objectif est de simuler une architecture d’entreprise en assurant la sécurité, la gestion des utilisateurs et l’accès à un service web.

Et créer  un laboratoire de tests de sécurité a été mis en place afin de simuler des attaques réalistes sur l’infrastructure Active Directory.

---
** 🎯 2. Objectifs du projet **
---

	- Mettre en place un pare-feu pfSense
	- Déployer un domaine Active Directory
	- Installer un serveur Web accessible depuis Internet
	- Sécuriser l’architecture avec une DMZ
	- Permettre l’accès depuis un poste client


	- Identifier d’éventuelles failles de sécurité
	- Tester la robustesse des comptes présents dans le domaine.
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
		- DMZ (en cours)

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




- 7- 🔐 Attaque réalisée :Nmap, Netdiscovrer, Kerberoasting

- Une attaque de type Kerberoasting a été effectuée afin de récupérer les tickets de service (TGS) associés aux comptes disposant d’un SPN (Service Principal Name).

- ⚙️ Outil utilisé
	- Commandes bash
	- Script GetUserSPNs.py issu de la suite Impacket

- 💻 Commande utilisée
```
python3 /usr/share/doc/python3-impacket/examples/GetUserSPNs.py \
monlabo.local/jdupont:******** \
-dc-ip 192.168.56.10 \
-request \
-outputfile ~/formationtssr/projetinfrastructure/recon/kerberoast_hashes
```

- ⚠️ Analyse de sécurité

- Cette attaque démontre que :

- les comptes de service peuvent être vulnérables si leurs mots de passe sont faibles
- un attaquant authentifié peut extraire des informations sensibles sans privilèges élevés

- Ce test met en évidence l’importance de la sécurisation des comptes Active Directory et démontre la nécessité de mettre en place des bonnes pratiques en matière de cybersécurité.



- ⚠️ 8. Problèmes rencontrés


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
