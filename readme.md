# Installation et configuration de Git sous Debian

```bash
sudo apt install git

# Creation du dossier
'''bash
cd projet
git init

### Création automatique du dossier .git (ne pas transférer).
'''bash 
git help config
git config --global user.email "ton.email@example.com"
git config --global user.name "Ton Nom"
git config --global color.ui true
git config --list
git config --global --list

# Travailler et sauvegarder
### Créer un fichier README
'''bash
touch readme.md
git status
git add "*.html"
git commit -m "message"


