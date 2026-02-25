Installation de git et configuration sous Debian
sudo apt install git

>Creation d'un dossier
cd  projet
git init




Creation d'un dossier .git automatic 
(à ne pas transférer)

>Configuration
git help config

git config --global "user.email"
git config --global "user.name"
git config --global  color.ui true

git config --list
git config --global --list

Travailler et sauvegarder
Creer un noueau fichier readme.md
touch readme.md 

git status
git add "*.html
git commit -m "message"

Creation dossier .gitignore
Ignorer des fichiers

touch .gitignore
tmp/
*.temp
temp/
log.txt

Vérifie que git applique 
git rm -r --cached tmp temp log.txt

Commit le .gitignore
git add .gitignore
git commit -m "Ajout du fichier .gitignore pour tmp, temp et log.txt"
git push

git commit -m "Ajout du fichier .gitignore pour tmp, temp et log.txt"
git push 
Ignore le fchier log.txt

Commande LOG
option oneline
git log --oneline

filter :
git log _p readme.md
git log -n 1 _p readme.md

Commande DIFF :
Voir la différence entre 2 fichiers
Git diff

Alias 
Alias git lg = git log amélioré

git config --global alias.lg "log --oneline --graph --all --decorate --color --name-status"


Branches
git checkout main

👉 Ça te déplace sur la branche main.

git checkout -b feature/login
✅ -b : crée la branche
Ou

git switch -c feature/login
-c : crée la branche

git add .
git commit -m "Ajout configuration Apache vhost"

Revenir sur main
git checkout main

Mettre à jour (si travail en équipe) :
git pull

On merge toujours DANS la branche sur laquelle on se trouve.

git switch main
git merge feature/apache-config


Revenir au code d'un fichier supprimé
git checkout uid nom.du.fichier

Visualise un fichier
git show + uudi (donné par le git lg)

1️⃣ Depuis le dépôt racine

Assure-toi d’être dans le dossier racine de ton projet local :

cd ~/formationtssr/projetinfrastructure
2️⃣ Ajouter le dépôt GitHub comme remote

Remplace tonpseudo et projetinfrastructure par tes infos GitHub :

git remote add origin https://github.com/tonpseudo/projetinfrastructure.git

Vérifie :

git remote -v

Tu devrais voir origin pour fetch et push.

3️⃣ Pousser la branche main
git push -u origin main

-u crée la tracking branch, tu pourras juste faire git push après.

Tous tes commits de main (y compris virtualisation/windowsserver) seront sur GitHub.

4️⃣ Pousser la branche feature/virtualisation

Si tu veux garder la branche feature sur GitHub :

git push -u origin feature/virtualisation

Cela permet de suivre la branche et de collaborer si besoin.

5️⃣ Vérifier sur GitHub

Ouvre ton dépôt GitHub → tu devrais voir :

Tous tes fichiers et dossiers (virtualisation, windowsserver, scripts .sh)

Toutes tes branches (main, feature/virtualisation)

L’historique des commits (git lg correspondra aux commits affichés sur GitHub).

6️⃣ Pour les prochaines modifications

Ensuite, la routine devient simple :

git add .
git commit -m "Nouveau message"
git push
