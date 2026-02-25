Installation de git et configuration sous Debian  

sudo apt install git  

#Creation d'un dossier  

'''cd projet
git init'''y





Creation d'un dossier .git automatic 
(à ne pas transférer)

#Configuration
'''git help config

git config --global "user.email"
git config --global "user.name"
git config --global  color.ui true

git config --list
git config --global --list'''
#Travailler et sauvegarder
#Creer un nouveau fichier readme.md
'''
touch readme.md 

git status
git add "*.html
git commit -m "message"
'''
#Creation dossier .gitignore
Ignorer des fichiers
'''
touch .gitignore
tmp/
*.temp
temp/
log.txt
'''
#Vérifie que git applique 
'git rm -r --cached tmp temp log.txt'

#Commit le .gitignore
'''
git add .gitignore
git commit -m "Ajout du fichier .gitignore pour tmp, temp et log.txt"
git push

git commit -m "Ajout du fichier .gitignore pour tmp, temp et log.txt"
git push 
'''
Ignore le fchier log.txt

#Commande LOG
option oneline
'git log --oneline'

##filter :
'''git log _p readme.md
git log -n 1 _p readme.md'''

#Commande DIFF :
##Voir la différence entre 2 fichiers
'Git diff'
#Alias 
##Alias git lg = git log amélioré
'
git config --global alias.lg "log --oneline --graph --all --decorate --color --name-status"
'
#Branches
##Se déplacer
'
git checkout main
'
#Crée branch -b
'
git checkout -b feature/login
'
## Se déplacer et créer avec switch
git switch -c feature/login
-c : crée la branche

git add .
git commit -m "Ajout configuration Apache vhost"

##Revenir sur main
'git checkout main'

#Mettre à jour (si travail en équipe) :
'
git pull
'
On merge toujours DANS la branche sur laquelle on se trouve.

git switch main
```git merge feature/apache-config


#Revenir au code d'un fichier supprimé
'git checkout uid nom.du.fichier'

#Visualise un fichier
##git show + uudi (donné par le git lg)


#Ajouter le dépôt GitHub comme remote

'git remote add origin https://github.com/tonpseudo/projetinfrastructure.git
'
Vérifie :

```git remote -v

# Pousser la branche main
git push -u origin main

-u crée la tracking branch, tu pourras juste faire git push après.

#Eviter les conflits
#Avant de commencer à modifier, faire avant : 
```git pull origin main
```git commit 
```git push origin main
	

