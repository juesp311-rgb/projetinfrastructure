# VLAN-20USERS

## Pré-requis

- Routage via ipatables (ubuntuserver)


# 🎯 Prochaine étape : Joindre VLAN-20USERS au domaine

```
# Remplace "Administrator" par ton user AD
Add-Computer -DomainName "lab.local" -Credential lab\Administrator -Restart
```
> Domaine
