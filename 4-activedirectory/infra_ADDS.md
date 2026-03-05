# Active Directory Home Lab (System Admnistration)
```
Infrastructure
│
├── network
│   ├── vlan-plan.md
│   ├── ip-addressing.md
│
├── active-directory
│   ├── ou-structure.md
│   ├── gpo-security.md
│
└── diagrams
    ├── network-datacenter.png

```



# Configurer le firewall
- allow SSH

# Plan d'adressage réseau
- Créer 8 VLAN01 - VLAN08

# Conception hierarchiques de l'infrastructure Active directory
![Infrastructure Active Directory](https://raw.githubusercontent.com/juesp311-rgb/projetinfrastructure/main/4-activedirectory/Corporate%20IT%20infrastructure%20diagram.png)

# Définir les forêts et les domaines, " des groupes utilisateurs" 
# La création d’une forêt, de domaines, d’OU et d’objets

>- 🌐 Conception hiérarchique AD DS avec PowerShell
 
- Création de la forêt (nouveau domaine racine)
```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
 
Install-ADDSForest `
-DomainName "entreprise.local" `
-DomainNetbiosName "ENTREPRISE" `
-InstallDNS `
-DatabasePath "C:\Windows\NTDS" `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
```
 
        - Résultat → Domaine racine : `entreprise.local`  
        - Serveur devient **contrôleur de domaine (DC)**  

 

-  Créer une OU dans le domaine racine
```powershell
New-ADOrganizationalUnit -Name "IT" -Path "DC=entreprise,DC=local" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Marketing" -Path "DC=entreprise,DC=local" -ProtectedFromAccidentalDeletion $true
```
 
        >- OU = conteneurs logiques pour les objets  
        >- Protection contre suppression accidentelle activée  



-  Ajouter des objets dans les OU
 
        - Ajouter un utilisateur
```powershell
New-ADUser -Name "Jean Dupont" -SamAccountName jdupont `
-UserPrincipalName jdupont@entreprise.local `
-Path "OU=IT,DC=entreprise,DC=local" `
-AccountPassword (Read-Host -AsSecureString "Mot de passe") `
-Enabled $true
```
 
        - Ajouter un ordinateur
```powershell
New-ADComputer -Name "PC01" -Path "OU=IT,DC=entreprise,DC=local"








# Connexion à plusieurs domaine
# Recherche et filtrage des Données AD DS en générant des requêtes
# Récupération d'objet de la corbeille
# Le contrôle d'accès dynamique
