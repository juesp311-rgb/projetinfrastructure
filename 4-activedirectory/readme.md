# Active Directory Home Lab (System Admnistration)


![Infrastructure Active Directory](https://raw.githubusercontent.com/juesp311-rgb/projetinfrastructure/main/4-activedirectory/Corporate%20IT%20infrastructure%20diagram.png)


# Définir AD DS
- le magasin central de tous les objets de domaine, tels que les comptes d’utilisateur, les comptes d’ordinateur et les groupes
-  AD DS fournit un répertoire hiérarchique offrant des possibilités de recherche, ainsi qu’une méthode d’application des paramètres de configuration et de sécurité pour les objets d’une entreprise.
- comprend des composants logiques et physiques
	- L’installation, la configuration et la mise à jour d’applications.
	- La gestion de l’infrastructure de sécurité.
	- L’activation du service d’accès à distance et de DirectAccess.
    	- L’émission et la gestion de certificats numériques.

## Les composants logiques
>**implémenter une conception AD DS appropriée pour une organisation**

- **Forêt**
	- → Regroupement d’un ou plusieurs domaines partageant le même schéma et une relation d’approbation automatique.

- **Arborescence de domaine (Tree)**
	- → Ensemble de domaines partageant un espace de noms DNS contigu au sein d’une même forêt.

- **Domaine**
	- → Unité administrative principale contenant des objets (utilisateurs, groupes, ordinateurs) et partageant une base de données commune.

- **Unité d’organisation (OU)**
	- → Conteneur logique dans un domaine permettant d’organiser les objets et de déléguer l’administration.

- **Conteneur (Container)**
	- → Objet de stockage par défaut dans un domaine (ex : Users, Computers), moins flexible qu’une OU (pas de délégation fine ni de GPO directe).

- **Schéma**
	- → Définit la structure de tous les objets et attributs dans la forêt (il est unique et commun à toute la forêt).
	- Le schéma est techniquement au niveau de la forêt

- Voici la hiérarchie du plus global au plus spécifique :

```
FORÊT
│
├── Schéma (commun à toute la forêt)
│
└── Arborescence de domaine (Tree)
     │
     └── Domaine
          │
          ├── Unité d’Organisation (OU)
          │     ├── OU
          │     │    └── Objets (utilisateurs, groupes, ordinateurs)
          │     └── Objets
          │
          └── Conteneurs par défaut
                ├── Users
                └── Computers

```
## Les composants physiques 
> Voici les composants physiques de Active Directory Domain Services (AD DS) classés du plus global (infrastructure réseau) au plus spécifique (serveur / rôle) :

- 🌍 1️⃣ Site

	- Représente un ou plusieurs réseaux IP bien connectés entre eux.
	- → Sert à optimiser la réplication et l’authentification.

- 🌐 2️⃣ Sous-réseau

	- Associe une plage d’adresses IP à un site.
	- → Permet à AD de savoir à quel site appartient un client.

- 🖥️ 3️⃣ Contrôleur de domaine (DC)

	- Serveur qui héberge AD DS et authentifie les utilisateurs.

- 📚 4️⃣ Magasin de données

	- Base de données AD (NTDS.dit) stockée sur le contrôleur de domaine.

-🌎 5️⃣ Serveur du catalogue global (GC)

	- Contrôleur de domaine qui contient une copie partielle de tous les objets de la forêt.
	- → Permet les recherches et l’authentification multi-domaines.

-🔐 6️⃣ Contrôleur de domaine en lecture seule (RODC)
	- DC avec base en lecture seule.
	- Utilisé dans les sites distants pour plus de sécurité.


#### 📊 Hiérarchie simplifiée
```
SITE
│
└── Sous-réseau
      │
      └── Contrôleurs de domaine
            ├── DC standard
            │     ├── Magasin de données (NTDS.dit)
            │     └── Peut être Catalogue Global
            │
            └── RODC

```




#








# Définir les utilisateurs, les groupes et les ordinateurs
## Créer des objets utilisateur

```powershell
New-ADUser -Name "Jean Dupont" `
-SamAccountName jdupont `
-UserPrincipalName jdupont@entreprise.local `
-Path "OU=Employes,DC=entreprise,DC=local" `
-AccountPassword (Read-Host -AsSecureString "Mot de passe") `
-Enabled $true
```


## Comptes de services administrés délégués

> 🔐 Type spécial de compte conçu pour exécuter des services Windows sans gestion manuelle du mot de passe.

> 📚 Types de comptes de service administrés

- 1️⃣ MSA (Managed Service Account)

	- Utilisable sur un seul serveur

	- Mot de passe géré automatiquement par AD


- 2️⃣ gMSA (Group Managed Service Account)

	- Un gMSA (Group Managed Service Account) est un compte de service spécial géré par Active Directory, conçu pour exécuter des services sur plusieurs serveurs sans avoir à gérer manuellement les mots de passe.

	- Recommandé aujourd’hui

	- Idéal pour :

		- Fermes IIS

		- Services répartis

		- Tâches planifiées sur plusieurs machines

- ⚙️ Fonctionnement

	- Le mot de passe est généré et changé automatiquement

	- Le serveur autorisé récupère le mot de passe auprès d’AD

	- Aucune intervention humaine nécessaire

#### 🛠️ Création d’un gMSA
- Créer le compte dans AD

```powershell
New-ADServiceAccount -Name gmsa-web `
-DNSHostName entreprise.local `
-PrincipalsAllowedToRetrieveManagedPassword "ServeursWeb"
```
- Installer le gMSA sur un serveur
```powershell
Install-ADServiceAccount -Identity gmsa-web
```
- Vérifier le compte
```powershell 
Test-ADServiceAccount gmsa-web
```
- Configurer le service pour utiliser le gMSA

	>- Dans les propriétés du service Windows → Connexion → mettre domain\gmsa-web$ comme compte.

	>- ⚠️ Note : le $ à la fin du nom est obligatoire pour les gMSA.




## Comptes de services administrés délégués
### 🔹 Définition

- Type spécial de compte de service administré utilisé pour déléguer l’authentification Kerberos à un service sur un serveur tout en conservant la gestion automatique du mot de passe.

- Il permet à un service sur un serveur d’utiliser un compte sécurisé sans que l’administrateur ait besoin de connaître ou gérer le mot de passe.

- Très utilisé pour les services distribués (IIS, SQL Server, services web) nécessitant des droits précis sur d’autres machines.

- Le mot de passe est géré automatiquement par AD.
- Le gMSA peut être utilisé par plusieurs serveurs autorisés.
- Le mot de passe est géré automatiquement par AD.

### Création d’un gMSA délégué (PowerShell)
- Créer le gMSA avec délégation Kerberos activée :
```powershell
New-ADServiceAccount -Name gmsa-delegue `
-DNSHostName entreprise.local `
-PrincipalsAllowedToRetrieveManagedPassword "ServeursWeb" `
-TrustedForDelegation $true
```
- Installer et vérifier le gMSA sur le serveur autorisé :
```powershell
Install-ADServiceAccount -Identity gmsa-delegue
Test-ADServiceAccount gmsa-delegue
```
- Configurer le service Windows pour utiliser ce compte :
	>- Nom du compte : domaine\gmsa-delegue$
	>- $ obligatoire pour les gMSA


### 🎓 Résumé

**Un compte de service administré est un compte spécial d’Active Directory dont le mot de passe est géré automatiquement par le système, destiné à exécuter des services de manière sécurisée.**


## 👥 Les objets de groupe dans Active Directory

- Dans Active Directory Domain Services (AD DS), un objet de groupe est un objet qui permet de regrouper des utilisateurs, des ordinateurs ou d’autres groupes afin de simplifier la gestion des droits et des permissions. 

### 📂 Types de groupes
-**Groupe de sécurité**
	- Sert à attribuer des permissions
	- Possède un SID (Security Identifier)
	- Peut être utilisé dans les ACL (listes de contrôle d’accès)

	- **✅ Utilisé pour la gestion des droits**

-**Groupe de distribution**
	- Sert uniquement pour les listes de diffusion (email)
	- Pas utilisable pour attribuer des permissions

**❌Mot de passe est géré automatiquement par AD.

### 🌍 Étendues (Scopes) des groupes

- 🔹**Groupe Local de Domaine**
	- Utilisé pour donner des droits sur des ressources dans un domaine spécifique
	- Peut contenir des membres de n’importe quel domaine de la forêt

- 🔹 **Groupe Global**
	- Contient des utilisateurs du même domaine
	- Peut être utilisé dans d’autres domaines

- 🔹 **Groupe Universel**
	- Peut contenir des membres de plusieurs domaines
	- Utilisable dans toute la forêt
	- Répliqué dans le catalogue global

### 📌 Bonnes pratiques (Méthode AGDLP)

- A → G → DL → P
- A = Accounts (Utilisateurs)
- G = Groupes Globaux
- DL = Groupes Locaux de Domaine
- P = Permissions

**👉 On met les utilisateurs dans des groupes globaux,
les groupes globaux dans des groupes locaux de domaine,
et on attribue les permissions aux groupes locaux.**

### 🎓 Résumé

**Un objet de groupe est un objet Active Directory permettant de regrouper des comptes afin de gérer les autorisations de manière centralisée et sécurisée.
Il existe deux types (sécurité, distribution) et trois étendues (global, local de domaine, universel)** 

---


## 💻 Objet Ordinateur

- 🔹 Définition

	- Un objet ordinateur représente une machine membre du domaine (PC, serveur, poste distant).

		- Chaque ordinateur membre du domaine possède une identité dans AD.

		- Il peut s’authentifier auprès du domaine et recevoir des stratégies de groupe (GPO).

- 🔹 Caractéristiques principales

	- Nom de l’ordinateur (doit être unique dans le domaine)

	- SID (Security Identifier) unique pour l’ordinateur

	- Mot de passe machine généré automatiquement et renouvelé par le domaine

	- Peut être membre de groupes pour appliquer des droits spécifiques

- 🔹 Rôle dans Active Directory

	- Permet l’authentification machine au domaine (ex. connexion réseau, partages).

	- Reçoit les GPO appliqués aux ordinateurs ou aux OU dans lesquelles il est placé.

	- Peut être utilisé dans des groupes pour déléguer des droits (ex. accès à des dossiers partagés).

### 🔹 Bonnes pratiques

- Placer les objets ordinateur dans des OU spécifiques selon leur rôle ou localisation

- Renommer les ordinateurs selon une convention de nommage claire

- Ajouter les ordinateurs aux groupes AD si nécessaire pour la gestion des permissions

### 🔹 Exemple d’usage

- Un serveur web WEB01 est ajouté au domaine → il devient un objet ordinateur dans l’OU “Serveurs”

- Les stratégies de sécurité et de déploiement logiciel sont automatiquement appliquées à cet objet.


---

## 💻 Conteneur Ordinateurs (Computers Container)
- 🔹 Définition

	- Conteneur par défaut dans Active Directory où sont placés les objets ordinateur qui rejoignent un domaine si aucune OU spécifique n’est définie lors de l’ajout.

		- C’est un objet logique mais non modifiable comme une OU : on ne peut pas lui appliquer directement des stratégies de groupe (GPO) ni déléguer l’administration.

		- Son chemin LDAP par défaut : CN=Computers,DC=nomdomaine,DC=com


- 🔹 Caractéristiques principales

	- Conteneur par défaut pour les ordinateurs du domaine

	- Ne supporte pas les GPO ou la délégation fine

	- Les ordinateurs peuvent ensuite être déplacés dans des OU pour une meilleure gestion

	- Permet de regrouper tous les ordinateurs non organisés


### 🔹 Différence entre Conteneur et OU

| Aspect                      | Conteneur | Unité d'organisation |
|-----------------------------|-----------|----------------------|
| Peut recevoir des GPO       | ❌ Non     | ✅ Oui                |
| Délégation d'administration | ✅ Oui     | ✅ Oui                |
| Déplacement d'objets        | ✅ Oui     | ✅ Oui                |
| Création par défault        | ✅ Oui     | ❌ Non                |


### 🔹 Bonnes pratiques

- Déplacer les objets ordinateur depuis le conteneur Computers vers des OU spécifiques selon leur rôle ou site

- Nommer les OU pour faciliter la gestion (ex. OU=Serveurs, OU=PostesClients)

- Appliquer les GPO sur les OU et non sur le conteneur par défaut

### 🔹 Exemple

- Un PC “PC01” rejoint le domaine → placé par défaut dans CN=Computers

- L’administrateur peut ensuite le déplacer dans :
```cmd
OU=PostesClients,DC=entreprise,DC=local
```

- Permettant l’application de stratégies spécifiques (ex. antivirus, scripts de logon, restrictions).



---


# Définir les forêts et les domaines AD DS
## 🌳 1️⃣ Domaine (Domain)
- 🔹 Définition

	- Un domaine est l’unité administrative principale dans Active Directory.

		- Il regroupe un ensemble d’objets (utilisateurs, groupes, ordinateurs, unités d’organisation…)

		- Partage une base de données commune (NTDS.dit) pour tous les objets

		- Possède une politique de sécurité unique et des relations de confiance avec d’autres domaines

- 🔹 Caractéristiques

	- Nom DNS unique (ex. entreprise.local)

	- Gestion centralisée des utilisateurs et ressources

	- Permet l’application de GPO (Group Policy Objects)

	- Chaque domaine possède un ou plusieurs contrôleurs de domaine (DC)



| Object                 | Description                                                                                                                                                                                                                                      |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Comptes d'utilisateurs | Les comptes d’utilisateur contiennent des informations sur les  utilisateurs, notamment les informations requises pour authentifier un  utilisateur pendant le processus de connexion et générer le jeton  d’accès de l’utilisateur.             |
| Comptes d'ordinateur   | Chaque ordinateur joint à un domaine possède un compte dans AD DS. Vous  pouvez utiliser des comptes d’ordinateur pour les ordinateurs joints à  un domaine de la même façon que vous utilisez des comptes d’utilisateur  pour les utilisateurs. |
| Groupes                | Les groupes organisent les utilisateurs ou les ordinateurs pour  simplifier la gestion des autorisations et des objets de stratégie de  groupe dans le domaine.                                                                                  |




- 🔹 Exemple

	- Domaine : entreprise.local

	- Objets : utilisateurs, ordinateurs, groupes

	- Contrôleur de domaine : serveur qui authentifie les utilisateurs et réplique AD



## 🌲 2️⃣ Forêt (Forest)
-  🔹 Définition

	- Une forêt est un regroupement de un ou plusieurs domaines qui partagent :

		- Le même schéma (structure et types d’objets)

		- Le catalogue global

		- Les relations de confiance implicites entre domaines

- Les objets suivants existent dans le domaine racine de la forêt :
	- Le rôle de contrôleur de schéma.
	- Le rôle de maître d’attribution des noms de domaine.
	- Le groupe Administrateurs de l’entreprise.
	- Le groupe Administrateurs du schéma.

- Une forêt AD DS est souvent décrite comme suit :

	-  Une limite de sécurité. Par défaut, aucun utilisateur en dehors de la forêt ne peut accéder aux ressources de la forêt. En outre, tous les domaines d’une forêt approuvent automatiquement les autres domaines de la forêt. Cela permet d’activer facilement l’accès aux ressources pour tous les utilisateurs d’une forêt, quel que soit le domaine auquel ils appartiennent.
	-  Une limite de réplication. Une forêt AD DS est la limite de réplication pour les partitions de schéma et de configuration dans la base de données AD DS. Par conséquent, les organisations qui souhaitent déployer des applications avec des schémas incompatibles doivent déployer des forêts supplémentaires. La forêt est également la limite de réplication pour le catalogue global. Le catalogue global permet de trouver des objets de n’importe quel domaine de la forêt.



#### Conseil

- En règle générale, une organisation ne crée qu’une seule forêt.

- Les objets suivants existent dans chaque domaine (y compris la racine de la forêt) :

   - Le rôle de maître RID.
   - Le rôle de maître d’infrastructure.
   - Le rôle de maître d’émulateur PDC.
   - Le groupe Admins du domaine.



- 🔹 Caractéristiques

	- Plus global que le domaine

	- Permet aux domaines de partager des informations et de se faire confiance

	- Chaque forêt a un schéma unique, qui définit tous les objets et attributs de tous les domaines de la forêt

- 🔹 Exemple

	- Forêt : entreprise.local

	- Contient :

		- Domaine entreprise.local (domaine racine)

		- Domaine sales.entreprise.local

		- Domaine it.entreprise.local

Tous les domaines partagent le même schéma et catalogue global


#### Cas pratique 

- Dans Active Directory Domain Services (AD DS), on ne « crée pas une forêt » directement sur un serveur via PowerShell tant que le rôle AD DS n’est pas installé. La création d’une forêt se fait lors de l’installation du rôle AD DS et de la promotion du serveur en contrôleur de domaine racine.

- Voici les étapes et commandes PowerShell pour créer une forêt :

- Installer le rôle AD DS

```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
```
	>- -IncludeManagementTools → installe les outils comme ADUC et PowerShell module.

- Créer une nouvelle forêt (Promotion du serveur)

```powershell
Install-ADDSForest `
-DomainName "entreprise.local" `
-DomainNetbiosName "ENTREPRISE" `
-InstallDNS `
-CreateDNSDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```
	>- 🔹 Paramètres importants :
		>- Paramètre	Description
		>- -DomainName	Nom DNS complet du domaine racine de la forêt
		>- -DomainNetbiosName	Nom NetBIOS du domaine (court)
		>- -InstallDNS	Installe et configure le serveur DNS si nécessaire
		>- -DatabasePath	Chemin du fichier NTDS.dit (base AD)
		>- -LogPath	Chemin des journaux de la base AD
		>- -SysvolPath	Chemin du dossier SYSVOL pour scripts et GPO
		>- -Force:$true	Supprime les confirmations interactives


- Redémarrage automatique
	>- Après l’exécution de Install-ADDSForest, PowerShell demandera de redémarrer le serveur pour compléter l’installation.
	>- Une fois redémarré, le serveur devient le contrôleur de domaine racine de la nouvelle forêt.

**⚠️ Notes importantes**

- Vous ne pouvez créer qu’une seule forêt par serveur en promotion initiale.

- Il est recommandé d’avoir un DNS fonctionnel sur ce serveur ou réseau.

- Après la création, vous pouvez ajouter des domaines enfants ou autres contrôleurs de domaine si nécessaire.



## Les relations d’approbation 
- 🔹 Définition

	- Une relation d’approbation (ou trust) est un lien logique entre deux domaines ou forêts qui permet aux utilisateurs d’un domaine (ou d’une forêt) d’accéder aux ressources d’un autre domaine sans avoir à créer de comptes supplémentaires.

		- Elle définit qui fait confiance à qui.

		- Active Directory utilise ces relations pour authentifier et autoriser les utilisateurs entre domaines.

- 🔹 Types de relations d’approbation

	-**Approvisionnement automatique (implicite)**
		- Parent → enfant dans une arborescence de domaine
		- Créée automatiquement lors de la création d’un domaine enfant
		- Bidirectionnelle par défaut : chaque domaine peut faire confiance à l’autre

	-**Approvisionnement externe (manuelle)**
		- Créée manuellement entre deux domaines distincts (même forêt ou forêts différentes)
		- Peut être :
			- Unidirectionnelle : un domaine fait confiance à l’autre, mais pas l’inverse
			- Bidirectionnelle : les deux domaines se font confiance mutuellement

	-**Approvisionnement de forêt**
		- Entre deux forêts AD DS différentes
		- Permet aux utilisateurs d’une forêt d’accéder aux ressources de l’autre
		- Souvent utilisé pour fusion d’entreprises ou échanges inter-domaines

	-**Approvisionnement transitif et non transitif**

| Type          | Définition                                                                    |
|---------------|-------------------------------------------------------------------------------|
| Transitif     | La confiance peut se propager à d’autres domaines de la forêt automatiquement |
| Non transitif | La confiance est limitée aux deux domaines directement concernés              |


### les principaux types d’approbations.

| Type d’approbation            | Description                  | Sens                            | Description                                                                                                                                                                                                                                                                                       |
|-------------------------------|------------------------------|---------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Parent et enfant              | Transitive                   | bidirectionnelle                | Lorsque vous ajoutez un nouveau domaine AD DS à une arborescence AD DS existante, vous créez des approbations parent et enfant.                                                                                                                                                                   |
| Arborescence/Racine           | Transitive                   | bidirectionnelle                | Lorsque vous créez une arborescence AD DS dans une forêt AD DS  existante, vous créez automatiquement une nouvelle approbation  arborescence/racine.                                                                                                                                              |
| Externe                       | Non transitive               | Sens unique ou bidirectionnelle | Les approbations externes permettent l’accès aux ressources avec un  domaine Windows NT 4.0 ou un domaine AD DS dans une autre forêt. Vous  pouvez également les configurer pour fournir une infrastructure pour une  **migration**.                                                              |
| Realm                         | Transitive ou non transitive | Sens unique ou bidirectionnelle | Les approbations de domaine établissent un chemin d’authentification  entre un domaine Windows Server AD DS et un domaine de protocole  **Kerberos** version 5 (v5) qui implémente à l’aide d’un service d’annuaire  autre que AD DS.                                                             |
| Forêt (complète ou sélective) | Transitive                   | Sens unique ou bidirectionnelle | Les approbations entre forêts AD DS permettent à deux forêts de partager des ressources.                                                                                                                                                                                                          |
| Raccourci                     | Non transitive               | Sens unique ou bidirectionnelle | Configurez des raccourcis d’approbations pour réduire le temps  nécessaire à l’authentification entre des domaines AD DS qui se trouvent  dans différentes parties d’une forêt AD DS. Par défaut, il n’existe pas  de raccourcis d’approbations, un administrateur doit les créer si  nécessaire. |


**Quand vous configurez des approbations entre des domaines dans la même forêt, entre des forêts ou pour un domaine externe, Windows Server crée un objet de domaine approuvé pour stocker les informations de l’approbation, telles que la transitivité et le type, dans AD DS. Windows Server stocke cet objet de domaine approuvé dans le conteneur Système de AD DS**


#### 🔹 Points clés

- Les relations d’approbation ne transfèrent pas les droits automatiquement → elles permettent seulement l’authentification inter-domaines.
- Les permissions doivent toujours être attribuées aux groupes ou ressources.
- AD crée automatiquement des trusts transitifs dans les forêts multi-domaines.

---


## 🗂️ Unité d’Organisation (OU)
- 🔹 Définition

- Une unité d’organisation (OU) est un conteneur logique dans Active Directory qui permet de regrouper des objets (utilisateurs, groupes, ordinateurs, autres OU) pour faciliter la gestion administrative et la délégation de contrôle.
	- Elle est utilisée pour organiser les objets selon différents critères : service, rôle, localisation, fonction, etc.
	- Contrairement aux conteneurs par défaut (Users, Computers), une OU permet l’application de stratégies de groupe (GPO) et la délégation d’administration.

- 🔹 Caractéristiques principales

- Peut contenir des objets et des sous-OU.
- Permet la délégation d’administration sans donner de droits sur tout le domaine.
- Supporte l’application de GPO pour configurer automatiquement les ordinateurs et utilisateurs.
- N’est pas créée automatiquement pour chaque rôle : il faut la définir selon la structure organisationnelle.

- 🔹 Bonnes pratiques

- Créer des OU logiques selon les besoins de l’entreprise (ex. OU=Marketing, OU=IT, OU=Serveurs).
- Éviter de mélanger trop d’objets différents dans la même OU.
- Utiliser les OU imbriquées pour structurer hiérarchiquement (ex. OU=IT → OU=PostesClients, OU=Serveurs).
- Appliquer les GPO au niveau de l’OU pour contrôler le paramétrage des objets.

- 🔹 Exemple concret

	>- Domaine : entreprise.local
	>- OU : OU=Marketing,DC=entreprise,DC=local
	>- Contenu : utilisateurs du service marketing, ordinateurs du service marketing
	>- Avantage : appliquer une GPO “paramètres sécurité” uniquement sur cette OU, ou déléguer l’administration à un responsable marketing sans toucher aux autres OU.


### Créer une Unité d’Organisation (OU)
- Importer le module Active Directory
```powsershell
Import-Module ActiveDirectory
```
	>- Ce module est installé automatiquement si le rôle RSAT-AD ou AD DS Tools est présent.

- Créer une nouvelle OU
```powsershell
New-ADOrganizationalUnit -Name "Marketing" -Path "DC=entreprise,DC=local" -Description "OU du service Marketing"
```
	- Exemple avec protection :
```powershell
New-ADOrganizationalUnit -Name "Marketing" -Path "DC=entreprise,DC=local" -ProtectedFromAccidentalDeletion $true
```


| Paramètre                        | Description                                                      |
|----------------------------------|------------------------------------------------------------------|
| -Name                            | Nom de l’OU (ex. Marketing)                                      |
| -Path                            | Emplacement dans l’AD (DN complet du domaine ou d’une OU parent) |
| -Description                     | Optionnel, description de l’OU                                   |
| -ProtectedFromAccidentalDeletion | Optionnel, protège l’OU contre suppression accidentelle          |


- Vérifier la création de l’OU
```powsershell
Get-ADOrganizationalUnit -Filter 'Name -eq "Marketing"'
```

- Ajouter des objets dans l’OU (facultatif)
>- Ajouter un utilisateur à l’OU :

```powershell
New-ADUser -Name "Jean Dupont" -SamAccountName jdupont `
-UserPrincipalName jdupont@entreprise.local `
-Path "OU=Marketing,DC=entreprise,DC=local" `
-AccountPassword (Read-Host -AsSecureString "Mot de passe") `
-Enabled $true
```

- ✅ Bonnes pratiques

	- Organiser les OU selon les services, rôles ou sites.
	- Activer la protection contre suppression accidentelle pour les OU importantes.
	- Appliquer des GPO au niveau de l’OU, pas dans le conteneur par défaut Computers.
	- 🌐 Processus PowerShell pour créer une OU et gérer des objets dans AD DS


### ✅ Résumé
1. Créer l’OU avec `New-ADOrganizationalUnit`  
2. Ajouter utilisateurs (`New-ADUser`) et ordinateurs (`New-ADComputer`) dans l’OU  
3. Appliquer GPO au niveau de l’OU  
4. Protéger l’OU contre suppression accidentelle avec `-ProtectedFromAccidentalDeletion $true`  

---


## 📦 Conteneurs génériques (Generic Containers)
- 🔹 Définition

	- Un conteneur générique est un objet de type conteneur dans Active Directory qui sert à regrouper d’autres objets AD (utilisateurs, ordinateurs, groupes, etc.) sans disposer des fonctionnalités complètes d’une unité d’organisation (OU).
		- Ils sont créés par défaut par AD pour organiser certains types d’objets.
		- Contrairement aux OU, on ne peut pas leur appliquer directement de GPO et ils ne permettent pas la délégation d’administration.
		- Exemple : les conteneurs par défaut Users et Computers.

- 🔹 Caractéristiques principales

	- Conteneur logique uniquement (pas d’administration avancée)
	- Fonctionnalités de gestion limitées
	- Peut contenir différents types d’objets AD
	- Ne peut pas recevoir de stratégies de groupe (GPO)
	- Ne permet pas de délégation de contrôle fine

#### Les objets ci-dessous sont affichés par défaut

- Domaine. Le niveau supérieur de la hiérarchie de l’organisation du domaine.
- Conteneur Builtin. Un conteneur qui stocke plusieurs groupes par défaut.
- Conteneur Ordinateurs. L’emplacement par défaut pour les nouveaux comptes d’ordinateur que vous créez dans le domaine.
- Conteneur Principaux de sécurité externes. L’emplacement par défaut pour les objets approuvés des domaines situés en dehors du domaine de AD DS local que vous ajoutez à un groupe dans le domaine AD DS local.
- Conteneur Comptes de service administrés. L’emplacement par défaut pour les comptes de service administrés. AD DS fournit une gestion automatique des mots de passe dans les comptes de service administrés.
- Conteneur Utilisateurs. L’emplacement par défaut pour les nouveaux comptes utilisateur et groupes que vous créez dans le domaine. Le conteneur Utilisateurs contient également l’administrateur, les comptes invités pour le domaine et certains groupes par défaut.
- UO de contrôleurs de domaine. L’emplacement par défaut pour les comptes d’ordinateur des contrôleurs de domaine. Il s’agit de la seule UO présente dans une nouvelle installation de AD DS.

#### Les objets qui sont masqués par défaut.

| Object               | Description                                                                                                                                           |
|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| LostAndFound         | Ce conteneur contient des objets orphelins.                                                                                                           |
| Données du programme | Ce conteneur contient des données Active Directory pour les  applications Microsoft, telles que les services de fédération Active  Directory (AD FS). |
| Système              | Ce conteneur contient les paramètres système intégrés.                                                                                                |
| Quotas NTDS          | Ce conteneur contient les données de quota de service d’annuaire.                                                                                     |
| Périphériques TPM    | Ce conteneur stocke les informations de récupération des périphériques TPM (Module de plateforme sécurisée).                                          |




- Remarque

**Les objets de stratégie de groupe ne peuvent pas être liés à des conteneurs dans un domaine AD DS. Pour lier des objets de stratégie de groupe dans le but d’appliquer des configurations et des restrictions, créez une hiérarchie d’unités d’organisation, puis liez-les aux objets de stratégie de groupe**




- 🔹 Bonnes pratiques

	- Déplacer les objets des conteneurs génériques vers des OU créées par	 l’administrateur pour bénéficier de GPO et de délégation.
	- Ne pas appliquer de stratégies directement sur les conteneurs génériques (impossible).
	- Les conteneurs servent surtout à l’organisation initiale des objets.

- Exemple concret

	- Un PC rejoint le domaine → placé par défaut dans Computers
	- Un utilisateur est créé sans OU spécifiée → placé dans Users
	- Pour appliquer des stratégies de sécurité, déplacer les objets vers des OU spécifiques comme `OU=PostesClients ou OU=Marketing`.


---


## 🌳 Conception hiérarchique dans AD DS
- 🔹 Définition

- Une conception hiérarchique consiste à organiser les objets et domaines d’Active Directory selon une structure logique reflétant l’organisation de l’entreprise, afin de faciliter :
	- La gestion des utilisateurs, ordinateurs et ressources
	- L’application des stratégies de groupe (GPO)
	- La délégation d’administration
	- La réplication et la sécurité

### 🔹 Principes de la hiérarchie

- Forêt (Forest)
	- Niveau le plus global
	- Regroupe tous les domaines d’une organisation
	- Partage un schéma et un catalogue global

- Domaines (Domain)
	- Regroupe un ensemble d’objets ayant une politique de sécurité commune
	- Chaque domaine possède un contrôleur de domaine (DC)
	- Les relations de confiance sont utilisées pour partager les ressources entre domaines

- Unités d’organisation (OU)
	- Conteneurs logiques pour organiser les objets
	- Permettent la délégation d’administration et l’application de GPO

- Objets (Users, Computers, Groups, MSA/gMSA)
	- Niveau le plus spécifique de la hiérarchie
	- Placés dans les OU pour bénéficier de stratégies et d’administration déléguée

#### 🔹 Avantages d’une conception hiérarchique

>✅ Clarté : structure reflète l’organisation réelle (services, sites, fonctions)
>
>✅ Sécurité : délégation fine sans donner de droits sur tout le domaine
>
>✅ Gestion simplifiée : groupes, OU et GPO appliqués de manière ciblée
>
>✅ Réduction des conflits : noms, stratégies et permissions organisés logiquement
>
>✅ Évolutivité : facile d’ajouter de nouveaux domaines, OU ou objets



### La création d’une forêt, de domaines, d’OU et d’objets
>- 🌐 Conception hiérarchique AD DS avec PowerShell

- Création de la forêt (nouveau domaine racine)
```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
-DomainName "entreprise.local" `
-DomainNetbiosName "ENTREPRISE" `
-InstallDNS `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```

	- Résultat → Domaine racine : `entreprise.local`  
	- Serveur devient **contrôleur de domaine (DC)**  



-  Créer une OU dans le domaine racine
```powershell
New-ADOrganizationalUnit -Name "IT" -Path "DC=entreprise,DC=local" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Marketing" -Path "DC=entreprise,DC=local" -ProtectedFromAccidentalDeletion $true
```

	>- OU = conteneurs logiques pour les objets  
	>- Protection contre suppression accidentelle activée  



-  Ajouter des objets dans les OU

	- Ajouter un utilisateur
```powershell
New-ADUser -Name "Jean Dupont" -SamAccountName jdupont `
-UserPrincipalName jdupont@entreprise.local `
-Path "OU=IT,DC=entreprise,DC=local" `
-AccountPassword (Read-Host -AsSecureString "Mot de passe") `
-Enabled $true
```

	- Ajouter un ordinateur
```powershell
New-ADComputer -Name "PC01" -Path "OU=IT,DC=entreprise,DC=local"
```

---
#### Arborescence hiérarchique

```
FORÊT : entreprise.local
│
├── Domaine racine : entreprise.local
│   ├── OU : IT
│   │    ├── Utilisateurs : Jean Dupont
│   │    └── Ordinateurs : PC01
│   ├── OU : Marketing
│   │    └── Utilisateurs : ...
│   └── OU : RH
│
└── Domaine enfant (facultatif) : sales.entreprise.local
     ├── OU : EquipeVentes
     └── OU : Administratif
```

---

#### ✅ Points clés

1. **Forêt → Domaine racine → OU → Objets**  
3. OU = conteneurs logiques permettant **délégation et GPO**  
4. Conteneurs par défaut (Users, Computers) ne permettent pas de GPO ni délégation  
5. Protection contre suppression accidentelle recommandée sur les OU importantes  

---






## 📌 Gestion des objets dans AD DS
- Dans Active Directory, tout est objet : utilisateurs, ordinateurs, groupes, unités d’organisation, conteneurs, comptes de service, etc.

- 🔹 Principes généraux
	- Chaque objet possède un nom unique et un identifiant de sécurité (SID).
	- Les objets ont des attributs / propriétés stockés dans la base de données AD (NTDS.dit).
	- La gestion des objets consiste à créer, modifier, déplacer, déléguer ou supprimer ces objets.

#### Créer un objet

- Utilisateur
```powershell
New-ADUser -Name "Jean Dupont" -SamAccountName jdupont `
-UserPrincipalName jdupont@entreprise.local `
-Path "OU=IT,DC=entreprise,DC=local" `
-AccountPassword (Read-Host -AsSecureString "Mot de passe") `
-Enabled $true
```

- Ordinateur
```powershell
New-ADComputer -Name "PC01" -Path "OU=IT,DC=entreprise,DC=local"
```

- Groupe
```powershell
New-ADGroup -Name "Marketing" -GroupScope Global -GroupCategory Security `
-Path "OU=Marketing,DC=entreprise,DC=local"
```

- Modifier un objet
```powershell
Set-ADUser -Identity jdupont `
-Title "Chef de projet" `
-Department "IT"
```
> Identity → identifie l’objet (nom, SamAccountName, ou DN)
>
> On peut modifier nom, titre, département, description, manager, mot de passe, etc.



- Déplacer un objet
```powershell
Move-ADObject -Identity "CN=Jean Dupont,OU=IT,DC=entreprise,DC=local" `
-TargetPath "OU=Marketing,DC=entreprise,DC=local"
```
> Permet de réorganiser les objets dans d’autres OU ou conteneurs.


- Supprimer un objet
```powershell
Remove-ADUser -Identity jdupont
Remove-ADComputer -Identity PC01
Remove-ADGroup -Identity "Marketing"
```

>- Supprime l’objet et ses références dans AD
>
>- Il est conseillé d’activer la protection contre suppression accidentelle sur les objets importants.


- Lire les propriétés d’un objet
```powershell
Get-ADUser -Identity jdupont -Properties *
```
---

#### Création et gestion des UO.

- Importer le module Active Directory
```powershell 
Import-Module ActiveDirectory
```

- Créer une nouvelle OU
```powershell
New-ADOrganizationalUnit -Name "IT" `
-Path "DC=entreprise,DC=local" `
-Description "OU du service IT" `
-ProtectedFromAccidentalDeletion $true
```

	- Exemple : pour créer une OU “Marketing” dans le même domaine :
```powershell
New-ADOrganizationalUnit -Name "Marketing" -Path "DC=entreprise,DC=local" -ProtectedFromAccidentalDeletion $true
```


- Modifier une OU
	>- Modifier par exemple la description ou le nom :
```powershell
Set-ADOrganizationalUnit -Identity "OU=IT,DC=entreprise,DC=local" `
-Description "OU modifiée pour le service IT"```


- Déplacer une OU ou ses objets
	>- Déplacer un objet (utilisateur, ordinateur, groupe) dans une OU :
```powershell
Move-ADObject -Identity "CN=Jean Dupont,OU=OldOU,DC=entreprise,DC=local" `
-TargetPath "OU=IT,DC=entreprise,DC=local"
```
	> - Permet de réorganiser les objets dans une structure hiérarchique logique.



- Supprimer une OU
```powershell
Remove-ADOrganizationalUnit -Identity "OU=Marketing,DC=entreprise,DC=local" -Recursive
```

	> - -Recursive → supprime également tous les objets contenus dans l’OU
	> - Veiller à utiliser la protection contre suppression accidentelle pour les OU critiques





- Lire les propriétés d’une OU
```powershell
Get-ADOrganizationalUnit -Identity "OU=IT,DC=entreprise,DC=local" -Properties *
```


####  Résumé visuel PowerShell pour OU
```powershell 
OU = IT
├─ Créer : New-ADOrganizationalUnit -Name "IT" -Path "DC=entreprise,DC=local"
├─ Modifier : Set-ADOrganizationalUnit -Identity "OU=IT,DC=..." -Description "Nouvelle description"
├─ Déplacer objets : Move-ADObject -Identity "CN=Jean,OU=OldOU,DC=..." -TargetPath "OU=IT,DC=..."
├─ Supprimer : Remove-ADOrganizationalUnit -Identity "OU=IT,DC=..." -Recursive
└─ Lire propriétés : Get-ADOrganizationalUnit -Identity "OU=IT,DC=..." -Properties *
```











###  Gestion et connexion à plusieurs domaines au sein d’une instance unique du Centre d’administration Active Directory.

- Connexion à Active Directory
```powershell
Import-Module ActiveDirectory
```

- Se connecter à un domaine spécifique

>- Pour exécuter des commandes sur un domaine particulier, utilisez -Server ou -DomainController :>
```powershell 
#### Se connecter au contrôleur de domaine DC01.domaine1.local
Get-ADUser -Filter * -Server "DC01.domaine1.local"
```

>- Ou avec le nom de domaine :
```powershell 
#### Utiliser le domaine domaine2.local
Get-ADComputer -Filter * -Server "domaine2.local"
```


#### Gestion de plusieurs domaines

- 🔹 Exécuter une commande sur plusieurs domaines
```powershell
$DomainControllers = @("DC01.domaine1.local","DC01.domaine2.local")

foreach ($DC in $DomainControllers) {
    Get-ADUser -Filter * -Server $DC | Select-Object Name, SamAccountName, Enabled
}
```
	> - foreach permet de parcourir plusieurs domaines et récupérer les objets AD.


- 🔹 Spécifier des informations d’identification pour un autre domaine
```powershell 
$Cred = Get-Credential
Get-ADUser -Filter * -Server "DC01.domaine2.local" -Credential $Cred
```
	>- Permet de se connecter avec un compte d’administrateur de ce domaine, si différent de votre domaine actuel.


#### Gérer des objets sur plusieurs domaines

	>- Exemple : déplacer un utilisateur dans un autre domaine
	>
	>- PowerShell ne peut pas déplacer directement un objet entre domaines, mais vous pouvez :


- 1. Exporter l’objet depuis le domaine source :
```powershell 
Get-ADUser -Identity "JeanDupont" -Server "DC01.domaine1.local" -Properties * | Export-Csv "JeanDupont.csv" -NoTypeInformation
```

- 2. Créer l’objet dans le domaine cible :
```powershell
Import-Csv "JeanDupont.csv" | ForEach-Object {
    New-ADUser -Name $_.Name -SamAccountName $_.SamAccountName `
    -UserPrincipalName $_.UserPrincipalName -Path "OU=IT,DC=domaine2,DC=local" `
    -AccountPassword (Read-Host -AsSecureString "Mot de passe") -Enabled $true
}
```

- 3. Supprimer l’objet dans le domaine source si nécessaire :
```powershell
Remove-ADUser -Identity "JeanDupont" -Server "DC01.domaine1.local"
```

- Bonnes pratiques
	- Toujours spécifier le serveur ou le domaine lorsqu’on gère plusieurs domaines.
	- Utiliser Get-Credential pour travailler avec des comptes ayant les droits nécessaires.
	- Automatiser avec foreach pour exécuter des cmdlets sur plusieurs domaines.
	- Documenter vos actions lorsque vous manipulez des objets entre domaines pour éviter des pertes de données.


#### Résumé 

| Action                                          | Cmdlet                                | Exemple                                              |
|-------------------------------------------------|---------------------------------------|------------------------------------------------------|
| Lister les utilisateurs                         | Get-ADUser -Filter * -Server <DC>     | Get-ADUser -Filter * -Server DC01.domaine2.local     |
| Lister les ordinateurs                          | Get-ADComputer -Filter * -Server <DC> | Get-ADComputer -Filter * -Server DC01.domaine1.local |
| Spécifier les credentials                       | -Credential $Cred                     | $Cred = Get-Credential                               |
| Déplacer un objet entre OU dans le même domaine | Move-ADObject                         | Move-ADObject -Identity ... -TargetPath ...          |
| Exporter / importer pour multi-domaines         | Export-Csv / Import-Csv               | Voir exemple ci-dessus                               |


---


### Recherche et filtrage des données AD DS en générant des requêtes.

- Importer le module Active Directory
```powershell
Import-Module ActiveDirectory
```

-  Rechercher tous les objets d’un type
```powershell
Get-ADUser -Filter *
```

	>- -Filter * → récupère tous les utilisateurs dans le domaine actuel.
	>
	>-Pour les ordinateurs : Get-ADComputer -Filter *
	>
	>-Pour les groupes : Get-ADGroup -Filter *

#### Filtrage avec des attributs spécifiques

- 🔹 Exemple : trouver un utilisateur précis
```powershell
Get-ADUser -Filter "SamAccountName -eq 'jdupont'"
```

Filter utilise une syntaxe de type LDAP.
Comparateurs possibles : -eq (égal), -ne (différent), -like (contient avec wildcard *), -notlike, -gt, -lt.



- 🔹 Exemple : filtrer par département
```powershell
Get-ADUser -Filter "Department -eq 'IT'" -Properties Title, Department
```
	>--Properties → permet de récupérer des attributs supplémentaires pour filtrer ou afficher.


- 🔹 Exemple : filtrer par titre contenant “Manager”
```powershell
Get-ADUser -Filter "Title -like '*Manager*'" -Properties Title
```

#### Combiner plusieurs conditions

- 🔹 ET logique
```powershell 
Get-ADUser -Filter "Department -eq 'IT' -and Enabled -eq $true"
```

- 🔹 OU logique
```powershell
Get-ADUser -Filter "Department -eq 'IT' -or Department -eq 'Marketing'"
```

### Trier et sélectionner des propriétés

- 🔹 Sélectionner des colonnes spécifiques
```powershell
Get-ADUser -Filter * -Properties SamAccountName, Department, Title |
Select-Object SamAccountName, Department, Title
```

- 🔹 Trier par nom ou département
```powershell
Get-ADUser -Filter * -Properties Department |
Sort-Object Department, Name
```

-  Requête avancée avec LDAPFilter
```powershell
#### Tous les utilisateurs activés dont le titre contient Manager
Get-ADUser -LDAPFilter "(&(objectClass=user)(objectCategory=person)(title=*Manager*)(enabled=TRUE))"
```
	>-LDAPFilter → syntaxe LDAP standard, souvent plus performante pour de grands domaines.


####  Exporter les résultats
- Pour analyse ou reporting :
```powsershell
Get-ADUser -Filter * -Properties SamAccountName, Department, Title |
Select-Object SamAccountName, Department, Title |
Export-Csv "C:\ADUsers.csv" -NoTypeInformation
```



#### Résumé

| Action                  | Cmdlet                            | Exemple                                                      |
|-------------------------|-----------------------------------|--------------------------------------------------------------|
| Lister les utilisateurs | Get-ADUser -Filter * -Server <DC> | Get-ADUser -Filter * -Server DC01.domaine2.local             |
| Filtrer par attribut    | -Filter "Attribut -eq 'Valeur'"   | Get-ADUser -Filter "Department -eq 'IT'"                     |
| Filtre avancé           | -LDAPFilter                       | Get-ADUser -LDAPFilter "(&(objectClass=user)(enabled=TRUE))" |
| Sélectionner colonnes   | Select-Object                     | Select SamAccountName, Department                            |
| Trier                   | Sort-Object                       | Sort-Object Department                                       |
| Exporter                | Export-Csv                        | Export-Csv "C:\ADUsers.csv"                                  |

---


#### Création et gestion des stratégies de mot de passe affinées.

- Pré-requis 
```powershell
Import-Module ActiveDirectory
```

- Créer une stratégie de mot de passe affinée

	>- Cmdlet principale :New-ADFineGrainedPasswordPolicy
```powershell
New-ADFineGrainedPasswordPolicy `
-Name "PSO_IT_Strict" `
-Precedence 10 `
-MinPasswordLength 12 `
-MaxPasswordAge (New-TimeSpan -Days 60) `
-MinPasswordAge (New-TimeSpan -Days 1) `
-PasswordHistoryCount 24 `
-ComplexityEnabled $true `
-ReversibleEncryptionEnabled $false `
-LockoutThreshold 5 `
-LockoutObservationWindow (New-TimeSpan -Minutes 30) `
-LockoutDuration (New-TimeSpan -Minutes 30)
```

- Appliquer la stratégie à un groupe ou utilisateur

	>- On utilise :
```powershell
Add-ADFineGrainedPasswordPolicySubject
```

- 🔹 Exemple : appliquer à un groupe
```powershell
Add-ADFineGrainedPasswordPolicySubject `
-Identity "PSO_IT_Strict" `
-Subjects "Groupe_IT"
```

- Voir les stratégies existantes
```powsershell
Get-ADFineGrainedPasswordPolicySubject -Identity "PSO_IT_Strict"
```

- Vérifier la stratégie effective pour un utilisateur
```powershell
Get-ADUserResultantPasswordPolicy -Identity jdupont
```

- Modifier une stratégie existante
```powershell
Set-ADFineGrainedPasswordPolicy `
-Identity "PSO_IT_Strict" `
-MinPasswordLength 14 `
-PasswordHistoryCount 30
```

- Supprimer une stratégie
```powershell
Remove-ADFineGrainedPasswordPolicy -Identity "PSO_IT_Strict"
```


#### Résumé 

- Créer :
```powershell
 New-ADFineGrainedPasswordPolicy
```
- Appliquer :
```powershell
 Add-ADFineGrainedPasswordPolicySubject
```

- Lister :
```powershell
Get-ADFineGrainedPasswordPolicy
```

- Voir application :
```powershell
 Get-ADUserResultantPasswordPolicy
```

- Modifier :
```powershell
Set-ADFineGrainedPasswordPolicy
```
- Supprimer :
```powershell
Remove-ADFineGrainedPasswordPolicy
```
---



### Récupération d’objets à partir de la corbeille de Active Directory.

- ⚠️ Prérequis :

	>-Corbeille AD activée
	>
	>-Niveau fonctionnel forêt ≥ Windows Server 2008 R2
	>
	>-Module ActiveDirectory chargé


- Vérifier si la Corbeille AD est activée
```powershell
Get-ADOptionalFeature "Recycle Bin Feature" |
Select-Object Name, EnabledScopes
```
	>- Si EnabledScopes est vide → la corbeille n’est pas activée.


- Activer la Corbeille AD (une seule fois par forêt)

	>- ⚠️ Action irréversible

```powershell
Enable-ADOptionalFeature `
-Identity "Recycle Bin Feature" `
-Scope ForestOrConfigurationSet `
-Target "entreprise.local"
```

-  Rechercher des objets supprimés
	>- Les objets supprimés ont l’attribut isDeleted = $true.

- 🔹 Lister tous les objets supprimés
```powershell
Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects
```

- 🔹 Rechercher un utilisateur supprimé précis
```powershell
Get-ADObject -Filter 'Name -like "*Jean*"' `
-IncludeDeletedObjects
```

- 🔹 Rechercher uniquement les utilisateurs supprimés
```powershell
Get-ADObject `
-Filter 'ObjectClass -eq "user" -and isDeleted -eq $true' `
-IncludeDeletedObjects
```

- Restaurer un objet supprimé
```powershell
Restore-ADObject
```

- 🔹 Restaurer par DistinguishedName
```powershell
Restore-ADObject -Identity "CN=Jean Dupont,CN=Deleted Objects,DC=entreprise,DC=local"
```

- 🔹 Restaurer automatiquement via recherche
```powershell
Get-ADObject `
-Filter 'Name -eq "Jean Dupont"' `
-IncludeDeletedObjects |
Restore-ADObject
```

- Restaurer vers une autre OU
	>-Si l’OU d’origine n’existe plus :
```powsershell
Restore-ADObject `
-Identity "CN=Jean Dupont,CN=Deleted Objects,DC=entreprise,DC=local" `
-TargetPath "OU=IT,DC=entreprise,DC=local"
```

- Vérifier la durée de rétention
```powershell
Get-ADObject "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=entreprise,DC=local" `
-Properties tombstoneLifetime
```
	>-Par défaut : 180 jours (selon version)



## Gestion des objets requis par la fonctionnalité de Contrôle d’accès dynamique.

- DAC repose sur :
	- Types de revendications (Claim Types)

	- Règles de revendication (Claim Rules)

	- Stratégies d’accès centralisées (Central Access Policies – CAP)

	- Règles d’accès centralisées (Central Access Rules – CAR)
	- Classification des ressources (File Server)



- Importer  modules
```powershell
Import-Module ActiveDirectory
Import-Module ActiveDirectoryRightsManagement
```


####  Gestion des types de revendications (Claim Types)

	>- Les Claim Types permettent d’utiliser des attributs AD (ex : Département) dans les règles d’accès.

- Créer un type de revendication
```powershell
New-ADClaimType `
-Name "DepartmentClaim" `
-SourceAttribute "department" `
-ID "DepartmentClaimID" `
-DisplayName "Department Claim"
```

-  Lister les Claim Types

```powershell
Get-ADClaimType -Filter *
```
- Modifier un Claim Type
```powershell
Set-ADClaimType -Identity "DepartmentClaim" -DisplayName "Dept Claim"
```
- Supprimer un Claim Type
```powershell
Remove-ADClaimType -Identity "DepartmentClaim"
```

####  Gestion des règles d’accès centralisées (Central Access Rules – CAR)

>- Les règles définissent les conditions d’accès (ex : Département = IT).

- Créer une règle d’accès centralisée
```powershell
New-ADCentralAccessRule `
-Name "IT_Access_Rule" `
-ProtectedFromAccidentalDeletion $true
```

- Lister les règles
```powesrshell
Get-ADCentralAccessRule -Filter *
```
#### Gestion des stratégies d’accès centralisées (Central Access Policies – CAP)

>- Les stratégies regroupent les règles d’accès.

- Créer une stratégie d’accès centralisée
```powsershell
New-ADCentralAccessPolicy -Name "IT_Access_Policy"
```
- Ajouter une règle à une stratégie
```powsershell
Add-ADCentralAccessPolicyMember `
-Identity "IT_Access_Policy" `
-Members "IT_Access_Rule"
```
- Lister les stratégies
```powsershell
Get-ADCentralAccessPolicy -Filter *
```

#### Activer la stratégie sur un serveur de fichiers

- Sur le serveur de fichiers :
```powsershell
Set-FileClassification `
-Path "D:\PartageIT" `
-CentralAccessPolicy "IT_Access_Policy"
```

- Gestion de la classification des ressources

	>- DAC fonctionne avec la classification des fichiers.

- Lister les propriétés de ressource
```powsershell
Get-ADResourceProperty -Filter *
```

- Créer une propriété de ressource
```powsershell
New-ADResourceProperty `
-Name "ConfidentialityLevel" `
-DisplayName "Confidentiality Level" `
-ResourcePropertyValueType String
```

### 🎯 Résumé rapide examen
```
**Claim Type** :
- New-ADClaimType
- Get-ADClaimType
- Set-ADClaimType
- Remove-ADClaimType

**Central Access Rule** :
- New-ADCentralAccessRule
- Get-ADCentralAccessRule

**Central Access Policy** :
- New-ADCentralAccessPolicy
- Add-ADCentralAccessPolicyMember
- Get-ADCentralAccessPolicy

**Resource Property** :
- New-ADResourceProperty
- Get-ADResourceProperty
```


### 🔐 Rappel important

- DAC permet :

	- Contrôle basé sur attributs utilisateur

	- Contrôle basé sur classification des fichiers

	- Gestion centralisée des accès

	- Audit avancé






