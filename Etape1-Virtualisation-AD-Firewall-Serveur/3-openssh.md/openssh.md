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
---
## Script Windowds
---
```
# Vérifier les paramètres du pare-feu Windows pour OpenSSH SSH Server
$FirewallRule = Get-NetFirewallRule -DisplayName "OpenSSH SSH Server (sshd)"
if ($FirewallRule) {
    Write-Host "La règle de pare-feu pour OpenSSH SSH Server existe."
    Write-Host "Profil:" $FirewallRule.Profile
    Write-Host "Activé:" $FirewallRule.Enabled
} else {
    Write-Host "La règle de pare-feu pour OpenSSH SSH Server n'existe pas."
}

# Vérifier les autorisations des fichiers SSH
$SshDirectory = "C:\ProgramData\ssh"
$AclRules = (Get-Acl $SshDirectory).Access | Where-Object {$_.IdentityReference -like "*NT AUTHORITY\SYSTEM*" -or $_.IdentityReference -like "*BUILTIN\Administrators*"}
if ($AclRules) {
    Write-Host "Les autorisations pour le répertoire SSH sont correctement configurées."
} else {
    Write-Host "Les autorisations pour le répertoire SSH ne sont pas correctement configurées."
}

# Vérifier le fichier de configuration SSH
$SshConfigFile = "C:\ProgramData\ssh\sshd_config"
if (Test-Path $SshConfigFile) {
    Write-Host "Le fichier de configuration SSH existe."
    $PermitRootLogin = Get-Content $SshConfigFile | Select-String -Pattern "^PermitRootLogin"
    if ($PermitRootLogin -like "*yes*") {
        Write-Host "La connexion root est autorisée dans le fichier de configuration SSH."
    } else {
        Write-Host "La connexion root n'est pas autorisée dans le fichier de configuration SSH."
    }
} else {
    Write-Host "Le fichier de configuration SSH n'existe pas."
}
```

- Ce script fait les vérifications suivantes :

Il vérifie si la règle de pare-feu pour "OpenSSH SSH Server (sshd)" existe et affiche son profil et son état (activé ou désactivé).
Il vérifie les autorisations du répertoire SSH (C:\ProgramData\ssh) pour s'assurer que "NT AUTHORITY\SYSTEM" et "BUILTIN\Administrators" ont accès.
Il vérifie si le fichier de configuration SSH (C:\ProgramData\ssh\sshd_config) existe et si la connexion root est autorisée (paramètre PermitRootLogin).


```
# Accéder au répertoire contenant le fichier de configuration SSH
cd C:\ProgramData\ssh

# Modifier le fichier de configuration SSH
(Get-Content sshd_config) -replace 'PermitRootLogin no', 'PermitRootLogin yes' | Set-Content sshd_config

# Redémarrer le service SSH
Restart-Service sshd
```

Après avoir exécuté ce script, la connexion root sera autorisée sur votre machine virtuelle Windows 10. Cependant, il est important de noter que l'autorisation de la connexion root est considérée comme un risque de sécurité. Il est recommandé de vous connecter avec un utilisateur non-root et d'utiliser sudo ou Run as administrator lorsque des privilèges élevés sont nécessaires. N'activez la connexion root que si cela est absolument nécessaire et assurez-vous de disposer de mots de passe forts et d'autres mesures de sécurité en place.


```
# Accéder au répertoire contenant le fichier de configuration SSH
cd C:\ProgramData\ssh

# Modifier le fichier de configuration SSH
(Get-Content sshd_config) -replace 'PermitRootLogin yes', 'PermitRootLogin no' | Set-Content sshd_config
Add-Content sshd_config "AllowUsers jdupont"

# Redémarrer le service SSH
Restart-Service sshd
```

Après avoir exécuté ce script, la connexion SSH directe en tant que root sera désactivée et seul l'utilisateur jdupont sera autorisé à se connecter via SSH. Assurez-vous que jdupont a un mot de passe fort et envisagez d'utiliser des clés SSH pour une sécurité accrue.


