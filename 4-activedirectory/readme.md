# Active Directory Home Lab (System Admnistration)
## Description

- Configure Microsoft windows to host Acitve Directory
- Déploie un controlleur de domaine
- Utilise powershell

## Catalogue global 

** Active directry domain services **
- = mécanisme de requete et d'index

## Service de réplication 
- =distribut données d'annuaire sur un réseau
- =concept de réplication active directory

-    Structure et technologies de stockage Active Directory
-    Rôles du contrôleur de domaine
-    Sdchéma Active Directory
-    Gestion des confiances
-    Technologies de réplication Active Directory
-    Technologies de recherche et de publication Active Directory   paramètres de stratégie de groupe DNS
-    Référence technique sur le schéma Active Directory


## Les composants logiques
 AD DS sont des structures que vous utilisez pour implémenter une conception AD DS appropriée pour une organisation

- Séparation 
- Schéma
- Domaine
- Arborescence de domaine
- Forêt : regroupement d'un ou plusieurs domaines
- Unité d’organisation
- Conteneur

## Les composants physiques 
	= objets tangibles


- Contrôleur de domaine
- Magasin de données
- Serveur du catalogue global
- Contrôleur de domaine en lecture seule (RODC)
- Site
- Sous-réseau

# Définir les utilisateurs, les groupes et les ordinateurs
** = objets **

## Créer des objets utilisateur

## comptes de service administrés de groupe

- comptes de service administrés de groupe 
> Network Load Balancing (NLB) ou des serveurs IIS,

- créer une clé racine KDS sur un contrôleur de domaine dans le domaine.
>>Add-KdsRootKey –EffectiveImmediately
>>>créez des comptes de service administrés de groupe à l’aide de l’applet de commande Windows PowerShell New-ADServiceAccount avec le paramètre –PrinicipalsAllowedToRetrieveManagedPassword.


## comptes de services administrés délégués

-  ** dMSA et gMSA ** 

- Credential Guard 


## objets de groupe 
- Étendues de groupe
	- Local
	- Domaine local
	- Global
	- Universel


## objets ordinateur

## Conteneur Ordinateurs
** =objet **

- Différence conteneur et une unité d’organisation.


# les forêts et les domaines AD DS
** Une forêt AD DS est une collection d’une ou plusieurs arborescences AD DS qui contiennent un ou plusieurs domaines AD DS. Domaines dans un partage de forêt : **
-  Une racine commune.
-  Un schéma commun.
-  Un catalogue global.

Un domaine AD DS est un conteneur d’administration logique pour les objets tels que :

    Utilisateurs
    Groupes
    Ordinateurs




##  forêt AD DS
** = conteneur de niveau supérieur **
- regroupement d’une ou plusieurs arborescences de domaines

>Conseil
>>En règle générale, une organisation ne crée qu’une seule forêt.

## un domaine AD DS 
**  = conteneur logique pour la gestion de l’utilisateur, de l’ordinateur, du groupe et d’autres objets **

- Objets =  Comptes d'utilisateurs, comptes d'ordinateur, groupes
- Le domaine AD DS contient un compte Administrateur et un groupe Admins du domaine. 

- Le compte Administrateur du domaine racine de la forêt dispose de droits supplémentaires.

	- Authentification
	- Autorisation

## les relations d’approbation 
** =accès aux ressources dans un environnement AD DS complexe **

Types d'approbation 
- Parent et enfant
- Arborescence/Racine
- Externe
- Realm
- Forêt (complète ou sélective)
- Raccourci

## des unités d’organisation
- = un objet de conteneur au sein d’un domaine

### Pourquoi créer des UO ?
- Pour regrouper des objets
- Pour déléguer le contrôle de l’administration des objets

## les conteneurs génériques 
- = tels que les utilisateurs et les ordinateurs
- Les principales différences entre les unités d’organisation et les conteneurs sont leurs fonctionnalités de gestion
- L’installation de AD DS crée par défaut l’UO des contrôleurs de domaine et plusieurs objets de conteneurs génériques


##  Utiliser une conception hiérarchique
- regrouper tous les ordinateurs dans une unité d’organisation si vous devez configurer tous les ordinateurs des administrateurs informatiques d’une certaine manière
- UO :  limitez sa profondeur à un maximum de 10 niveaux dans un souci de facilité de gestion

>Remarque
>
>>Les applications qui fonctionnent avec AD DS peuvent imposer des restrictions sur la profondeur d’UO au sein de la hiérarchie, pour les éléments de la hiérarchie qu’elles utilisent.


# Gérer les objets et leurs propriétés dans AD DS
## Centre d'administration Active Directory

-  la gestion des objets AD DS 
> Taches : 
>>    Création et gestion des comptes d’utilisateurs, d’ordinateurs et de groupes.
>>    Création et gestion des UO.
>>    Gestion et connexion à plusieurs domaines au sein d’une instance unique du Centre d’administration Active Directory.
>>    Recherche et filtrage des données AD DS en générant des requêtes.
>>    Création et gestion des stratégies de mot de passe affinées.
>>    Récupération d’objets à partir de la corbeille de Active Directory.
>>    Gestion des objets requis par la fonctionnalité de Contrôle d’accès dynamique.

## Windows Admin Center
** = console web **
- gérer les serveurs au lieu d’utiliser des Outils d’administration de serveur distant.



>Remarque
>
>Vous ne devriez pas installer Windows Admin Center sur un ordinateur serveur qui est configuré en tant que contrôleur de domaine AD DS.
> le télécharger et l’installe
>activer le port TCP approprié sur le pare-feu local
>
>À moins que vous n’utilisiez un certificat provenant d’une autorité de certification approuvée, la première fois que vous exécutez Windows Admin Center, vous êtes invité à sélectionner un certificat client. Veillez à sélectionner le certificat intitulé Client Windows Admin Center.



## Outils d’administration de serveur distant
 Remarque

Vous activez les outils RSAT 

## Autres outils de gestion AD DS


- Module Active Directory pour Windows PowerShell
- Utilisateurs et ordinateurs Active Directory
- Sites et services Active Directory
- Domaines et approbations Active Directory
- Composant logiciel enfichable MMC Active Directory Schéma




