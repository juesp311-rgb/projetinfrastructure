# 🔐 ÉTAPE 2 — Hardening minimal obligatoire

## Ubuntu Server

###  Mise à jour complète du système

> Mettre à jour les paquets
>
>Supprime les dépendances

```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
```
> Vérifie

```bash
lsb_release -a
uname -r
```

### Création d’un utilisateur admin
⚠️ On évite d'utiliser root directement.

> Crée un utilisateur adminsys

```bash
sudo adduser adminsys
```
> Puis ajouter aux sudoers 

```bash
sudo usermod -aG sudo adminsys
```

> Voir tous les utilisateurs du système
```bash 
cat /etc/passwd
```
>> Voir utilisateur dans le groupe sudo
```bash
getent group sudo
```
> Voir  seulement les utilisateurs “normaux” (humain)
** commande la plus utile en pratique **

```bash
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```
> Changer utilisateur
```bash
sudo su - utlisateur
```

### Configurer SSH 

> Configuration sshd_config
```bash
sudo nano /etc/ssh/sshd_config
```

> Modiier 
```bash 
PermitRootLogin no
PasswordAuthentication yes
```

> Redémarrer SSH
```bash
sudo systemctl restart ssh
```

> Vérifier la configuration active
```bash
sudo sshd -T | grep permitrootlogin
sudo sshd -T | grep passwordauthentication
```

#### Erreur fréquentes dans sshd_config qui peuvent bloquer complètement l'accès SSH au serveur Ubuntu

>Configuration dangereuse :

```bash
PasswordAuthentication no
```

** Si tu n’as pas encore installé de clé SSH, tu ne pourras plus te connecter du tout.**

> Vérifier avant :
```bash
ls ~/.ssh
```

> Désactive root sans avoir d’utilisateur sudo
>>Configuration 
```bash
PermitRootLogin no
```
** Vérifie avant si firewall allow OpenSSH **

#### 🔐 Configuration SSH simple  (courante sur Ubuntu)

> Dans /etc/ssh/sshd_config :
```bash
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
MaxAuthTries 3
```

> Ensuiste redémarrer
```bash
sudo systemctl restart ssh
```

### Sécuriser ssh
> Sur Kali (ordinateur hôte)
>
>>Créer une clé ssh
```bash
ssh-keygen -t ed25519
```
>
>>Vérifier la clé
```bash
ls ~/.ssh/
```

> Copier la clé vers la VM Ubuntu
>
>> Connexion ssh autorisée seulement avec utilisateur adminsys
>
```bash
ssh-copy-id adminsys@IP_DE_LA_VM
```
>> Connexion sans mot de passe 

> Ensuite seulement sécuriser SSH
>
>>Dans la vm Ubuntu
>
```bash
cd /etc/ssh/sshd_config
```
```bash
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```
> Vérifie avant de redemarrer ssh
>
>>Rien ne dois apparaître
>
```bash
sudo sshd -t
```
> Redémarrer le service SSH
```bash
sudo systemctl restart ssh
```
#### 🛡️ Bonus sécurité très recommandé
>Installer Fail2Ban pour bloquer les attaques SSH :
```bash
sudo apt install fail2ban
```

### Activer le firewall (UFW)
** ubuntu utilise UFW **
> Autoriser SSH
```bash
sudo ufw allow OpenSSH
```

> Activer le firewall
```bash
sudo ufw enable
```

> Vérifier 
```bash
sudo ufw status
```
** 💡 Astuce : Si jamais tu actives UFW avant d’autoriser SSH, tu peux perdre l’accès à la VM. Toujours autoriser les ports nécessaires avant.**


### Désactiver root ssh
** bonne pratique**
**s’assurer que tu peux te connecter via un autre utilisateur avec sudo, sinon tu risques de perdre l’accès à ta VM.**



### Sécuriser ssh
>  Générer une clé SSH sur Kali (ton hôte)
```bash
ssh-keygen -t ed25519 -C "kali@ssh"
```
> Vérifie 
```bash
ls ~/.ssh/id_ed25519
ls ~/.ssh/id_ed25519.pub
```
** Clé privée et clé publique **

> Copier la clé sur ton serveur Ubuntu
```bash
ssh-copy-id adminsys@IP_DU_SERVEUR
```
>Modifier la configuration SSH
```bash
sudo nano /etc/ssh/sshd_config
```

```bash
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
AllowUsers adminsys
```

> Vérifier avant de redémarrer SSH (important)
```bash
sudo sshd -t
```
> Redémarrer le service SSH
```bash
sudo systemctl restart ssh
```

>Tester la connexion
```bash
ssh adminsys@IP_DE_TA_VM
```
