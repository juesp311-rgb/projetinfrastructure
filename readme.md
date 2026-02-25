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
