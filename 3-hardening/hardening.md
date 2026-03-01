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

### Sécuriser SSH (important)

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

> Désactiver root sans avoir d’utilisateur sudo
>>Configuration 
```bash
PermitRootLogin no
```
** Vérifie avant si firewall allow OpenSSH **

#### 🔐 Configuration SSH simple et sécurisée (courante sur Ubuntu)

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



