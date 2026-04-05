#  Installer OpenSSH

```
# Vérifier si OpenSSH est disponible
Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH*"
```

```
# Installer le serveur SSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

```
# Démarrer le service
Start-Service sshd
```

``` # Activer au démarrage automatique
Set-Service -Name sshd -StartupType Automatic
```

```
# Vérifier que le service tourne
Get-Service sshd
```

---

## Commandes utiles

- Supprimier anciennes clé
```
ssh-keygen -f '/home/jukali/.ssh/known_hosts' -R '192.168.56.10'
```

- Sur AD-Server — Modifier les utilisateurs

```
# Désactiver le changement de mot de passe à la première connexion
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $false
Set-ADUser -Identity "mmartin" -ChangePasswordAtLogon $false
Set-ADUser -Identity "pdurand" -ChangePasswordAtLogon $false
```


