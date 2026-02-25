# Git – Installation et utilisation

## Installation de Git sous Debian

```bash
sudo apt install git

```

## Creation d'un dossier
```bash
cd  projet
git init
```

### La creation du dossier .git se fait automatiquement
Attention de ne pas envoyer le fichier .git lors de l'envoie d'un dossier sur un server.
Ce fichier est caché et il est lourd

## Configuration
```bash
git help config

git config --global "user.email"
git config --global "user.name"
git config --global  color.ui true

git config --list
git config --global --list

```

## Travailler
Creer un noueau fichier readme.md
```bash
touch readme.md 
```

## Ajout et commit
```bash 
git status
git add "*.html  
git commit -m "message"

```
Fonction uniquement pour les fichiers déjà trackés 
```bash
git commit -am "Message"
```


## Créer .gitignore
```bash
touch .gitignore
git add --all
git commit -m "Ajout de fichiers ignorés"
```
Puis dans ce fichier : 
log.txt
*.tmp
tmp/*


## Commande LOG
```bash
```bash
touch .gitignore
git add --all
git commit -m "Ajout de fichiers ignorés"
```
Création d'un alias

```bash
git lg```

```


## Commande DIFF : voir la différence entre 2 fichiers
```bash
git diff
```

## Branches
#### Créer une branche

```bash
git checkout -b feature/login
```
-b : crée la branche

ou 
```bash
git switch -c feature/login
```
-c : crée la branche


#### Se déplacer
Revenir sur la branche main

```bash
git checkout main
```

ou 

```bash
git switch
```
Attention : on merge dans la branche dans laquelle on se trouve


## Mettre à jour le gitHub
#### Vérifier statut et la branche

```bash
git status
git branch
```

#### Récupérer les changements du dépôt distant
Avant de pousser tes modifications, il est important de synchroniser ton dépôt local avec GitHub :
```bash
git pull origin main
```

Si tu préfères rebaser tes changements locaux au lieu de faire un merge automatique :
```bash
git pull --rebase origin main
```

#### Ajouter les fichiers modifiés ou nouveaux
```bash
git add .
```

#### Faire un commit
```bash
git commit -m "Description claire de ce que tu as changé"
```


#### Pousser les modifications sur GitHub
```bash
git push origin main
```

ou si c'est la première fois, option -u

```bash 
git push -u origin main
```

#### Vérifier que tout est à jour
```bash 
git status
git lg
```

#### Astuces pour éviter les conflits
Toujours faire un git pull avant de commencer à modifier des fichiers.


