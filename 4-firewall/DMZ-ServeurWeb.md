---
## DMZ
---

## Pré-requis

```
Internet > pfSense (Wan 10.0.2.15 -Lan 192.168.56.2- DMZ 192.168.100.2
                         	     Reseau privé      Reseau interne
Lan :
	 AD Server : DC/DNS/DHCP
	Machine Hote (vboxnet0 - Réseau privé hôte)
Connecté par 
DNS/Kerberos/LDAP

DMZ - 192.168.00.0/24
	SRV-Web : 192.168.100.10 : IIS + SQL
	Interface Virtualbox 
		Adatpter 1 : NAT
		Adapter 2 : vboxnet0 (admin RDP)
		Adapter 3 : Réseau Internet DMZ (AD-Server_pfsense-SRV-web)
```




- Étape 1 — VirtualBox : ajouter l'adaptateur dans AD-Server

  	- Adapter 1 → LAN (192.168.56.10)  ✅ on ne touche pas
  	- Adapter 2 > NAT
  	- **  Ajout ** Adapter 3 > Réseau interne  : 192.168.100.5


- Étape 2 — Windows : identifier la nouvelle interface

```
# Lister toutes les interfaces et leur index
Get-NetAdapter | Select-Object Name, InterfaceIndex, Status, MacAddress
```
```
# Vérifier qu'elle n'a pas d'IP assignée
Get-NetIPAddress | Select-Object InterfaceAlias, IPAddress, PrefixLength
```

``` Remove-NetIPAddress & RemoveNetIProute ```

- Étape 3 — Assigner l'IP statique sur la nouvelle interface DMZ
```
# ⚠️ Remplace "Ethernet 2" par le nom exact trouvé à l'étape 2

$interfaceDMZ = "Ethernet 3"
$ipDMZ        = "192.168.100.5"
$prefixDMZ    = 24
$gwDMZ        = "192.168.100.2"   # OPT1 pfSense

# Assigner l'IP (pas de passerelle ici, voir note ci-dessous)
New-NetIPAddress `
    -InterfaceAlias $interfaceDMZ `
    -IPAddress      $ipDMZ `
    -PrefixLength   $prefixDMZ
```

>⚠️ Ne pas mettre de passerelle sur cette interface — AD-Server a déjà sa gateway sur le LAN (192.168.56.2). Deux passerelles = conflits de routage.>


- Étape 4 — Ajouter une route statique vers la DMZ
> Pour qu'AD-Server sache répondre aux requêtes venant de 192.168.100.0/24 :
```
# Récupère l'index de la nouvelle interface
$idx = (Get-NetAdapter -Name "Ethernet 2").InterfaceIndex

# Route statique persistante vers le subnet DMZ
New-NetRoute `
    -DestinationPrefix "192.168.100.0/24" `
    -InterfaceIndex    $idx `
    -RouteMetric       10

# Vérifier la route
Get-NetRoute -DestinationPrefix "192.168.100.0/24"
```

- Étape 5 — Vérifier le pare-feu Windows sur AD-Server
```
# Autoriser les ports AD depuis la DMZ (DNS, Kerberos, LDAP, RPC)
$ports = @(
    @{Name="DNS-DMZ";     Protocol="TCP"; Port=53},
    @{Name="DNS-UDP-DMZ"; Protocol="UDP"; Port=53},
    @{Name="Kerberos-DMZ";Protocol="TCP"; Port=88},
    @{Name="LDAP-DMZ";    Protocol="TCP"; Port=389},
    @{Name="LDAPS-DMZ";   Protocol="TCP"; Port=636},
    @{Name="SMB-DMZ";     Protocol="TCP"; Port=445},
    @{Name="RPC-DMZ";     Protocol="TCP"; Port=135}
)

foreach ($p in $ports) {
    New-NetFirewallRule `
        -DisplayName    $p.Name `
        -Direction      Inbound `
        -Protocol       $p.Protocol `
        -LocalPort      $p.Port `
        -RemoteAddress  "192.168.100.0/24" `
        -Action         Allow `
        -Profile        Any
}

Write-Host "Règles pare-feu créées ✓"
```

- Étape 6 — Test depuis AD-Server
```
# Vérifier que l'IP DMZ est bien là
Get-NetIPAddress -InterfaceAlias "Ethernet 3"

# Tester la connectivité vers SRV-Web (une fois qu'il est en DMZ)
Test-NetConnection -ComputerName 192.168.100.10 -Port 80
Test-NetConnection -ComputerName 192.168.100.10 -Port 3389

# Ping
ping 192.168.100.10

```

- Résumé de l'état final
```
Ethernet (LAN)Réseau privé hôte192.168.56.10192.168.56.2 ✅
Ethernet 2 (DMZ)Réseau interne DMZ192.168.100.5❌ aucune
```

---
## Configuration SRV-Web
---


```
# Identifier l'interface avec l'IP APIPA
Get-NetAdapter | Select-Object Name, InterfaceIndex, Status
Get-NetIPAddress | Where-Object {$_.IPAddress -like "169.254.*"} | Select-Object InterfaceAlias, IPAddress
```
>Identifier l'interface  Ethernet 3 :


```
# ── CONFIG ──────────────────────────────────────────
$iface    = "Ethernet 3"        # nom exact de ton interface DMZ
$ip       = "192.168.100.10"    # IP fixe SRV-Web en DMZ
$prefix   = 24
$gw       = "192.168.100.2"     # OPT1 pfSense
$dns      = "192.168.100.5"     # AD-Server côté DMZ (interface qu'on vient d'ajouter)
# ────────────────────────────────────────────────────

# 1. Supprimer l'APIPA et toute config existante sur cette interface
Remove-NetIPAddress    -InterfaceAlias $iface -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute        -InterfaceAlias $iface -Confirm:$false -ErrorAction SilentlyContinue

# 2. Assigner l'IP statique + passerelle
New-NetIPAddress `
    -InterfaceAlias $iface `
    -IPAddress      $ip `
    -PrefixLength   $prefix `
    -DefaultGateway $gw

# 3. Assigner le DNS (AD-Server via son IP DMZ)
Set-DnsClientServerAddress `
    -InterfaceAlias $iface `
    -ServerAddresses $dns

# 4. Vérification
Write-Host "`n=== IP ===" -ForegroundColor Cyan
Get-NetIPAddress -InterfaceAlias $iface | Select-Object IPAddress, PrefixLength

Write-Host "`n=== DNS ===" -ForegroundColor Cyan
Get-DnsClientServerAddress -InterfaceAlias $iface

Write-Host "`n=== Ping gateway ===" -ForegroundColor Cyan
Test-NetConnection -ComputerName $gw -InformationLevel Quiet

Write-Host "`n=== Ping AD-Server DMZ ===" -ForegroundColor Cyan
Test-NetConnection -ComputerName $dns -InformationLevel Quiet
```

- Résultat attendu
```
=== IP ===
IPAddress      PrefixLength
---------      ------------
192.168.100.10    24

=== DNS ===
ServerAddresses : {192.168.100.5}

=== Ping gateway ===
True

=== Ping AD-Server DMZ ===
True
```

> LAN : 192.168.56.0/24
> DMZ : 192.168.100.0/24


- Analyse de la configuration pfSense via SSH
	- 1. Vérifier les interfaces
```
ifconfig | grep -E "^[a-z]|inet "
```

> Tu dois voir 3 interfaces avec leurs IPs : LAN 192.168.56.2, WAN 10.0.2.15, OPT1 192.168.100.2


- 2. Vérifier les routes
```
netstat -rn
```

> Tu dois voir des routes pour 192.168.56.0/24, 192.168.100.0/24 et la route WAN.



- 3. Tester la connectivité vers les serveurs
```
# Ping AD-Server (LAN)
ping -c 3 192.168.56.10

# Ping SRV-Web (DMZ)
ping -c 3 192.168.100.10

# Ping AD-Server depuis le subnet DMZ
ping -c 3 -S 192.168.100.2 192.168.56.10
``

```
4. Vérifier les règles de firewall actives
```
pfctl -sr | grep -E "192.168.56|192.168.100"
```

> Tu dois voir des règles pass et block entre les deux subnets.


- 5. Vérifier le NAT
```
pfctl -sn
```

> Tu dois voir une règle NAT pour 192.168.100.0/24 vers le WAN (pour l'accès internet de la DMZ).


- 6. Test isolation LAN → DMZ (le plus important)
```
# Simuler un paquet du LAN vers la DMZ — doit être BLOQUÉ
pfctl -s rules | grep "100.0"
```

####  Analyse complète de ta config :

- Routing table — OK
```
192.168.56.0/24  → em1  ✅ LAN
192.168.100.0/24 → em2  ✅ DMZ
0.0.0.0          → em0  ✅ WAN (gateway 10.0.2.2)
```

> Les 3 interfaces sont bien routées.

- NAT — OK
```
nat on em0 from 192.168.56.0/24  ✅ LAN sort sur Internet
nat on em0 from 192.168.100.0/24 ✅ DMZ sort sur Internet
```
- Règles firewall — Problèmes détectés
> Firewall → Rules → OPT1 → Ajouter 



```
Action 	Proto	Source			Destination	Port	
Pass	TCP	192.168.100.0/24	192.168.56.10	53
Pass	UDP	192.168.100.0/24	192.168.56.10	53
Pass	TCP	192.168.100.0/24	192.168.56.10	88
Pass	TCP	192.168.100.0/24	192.168.56.103	89
Pass	TCP	192.168.100.0/24	192.168.56.10	445
Pass	TCP	192.168.100.0/24	192.168.56.101	35
Block	Any	192.168.100.0/24	192.168.56.0/24	any

```

- Sur AD-Server, configure fierewall :
```
# Autoriser le ping depuis la DMZ
New-NetFirewallRule `
    -DisplayName "ICMP DMZ" `
    -Direction Inbound `
    -Protocol ICMPv4 `
    -RemoteAddress "192.168.100.0/24" `
    -Action Allow

# Vérifier que l'interface DMZ est bien up
Get-NetIPAddress -InterfaceAlias "Ethernet 2"
```

- Test SRV-Web (PowerShell)
```
# Ping vers AD-Server depuis SRV-Web
ping 192.168.56.10

# Ping vers AD-Server via son IP DMZ
ping 192.168.100.5

# Test DNS
nslookup monlabo.local 192.168.100.5
```

- Résultat 
```
ping 192.168.56.10 = reponse
ping 192.168.100.5 = reponse

nslookup monlabo.local 192.168.100.5 
Serveur : Unknows 
address 192.168.100.5

Nom  : monloabo.local
Addresse : fd17....
192.168.100.5
192.168.56.10
10.0.3.15
```

```
Tout fonctionne parfaitement !
Ce que ça confirme :

ping 192.168.56.10 ✅ — SRV-Web joint AD-Server via le LAN
ping 192.168.100.5 ✅ — SRV-Web joint AD-Server via la DMZ
nslookup monlabo.local ✅ — DNS fonctionne, AD-Server résout correctement le domaine
```


```
Internet
    │
 pfSense
  /    \
LAN     DMZ
│         │
AD-Server  SRV-Web
56.10      100.10
│         │
└─────────┘
  DNS/LDAP/Kerberos
  autorisés via règles
  pfSense OPT1
```

- Teste  domain join depuis SRV-Web 
```
nltest /sc_verify:monlabo.local
Test-ComputerSecureChannel -Verbose
```



- 3. Base de données SQL sur SRV-Web
```
# Créer la base
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "CREATE DATABASE IntranetDB"

# Créer la table
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "USE IntranetDB; CREATE TABLE Employes (ID INT PRIMARY KEY IDENTITY, Nom NVARCHAR(50), Prenom NVARCHAR(50), Departement NVARCHAR(50), Email NVARCHAR(100), DateCreation DATETIME DEFAULT GETDATE())"

# Insérer des employés test
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "USE IntranetDB; INSERT INTO Employes (Nom, Prenom, Departement, Email) VALUES ('Dupont', 'Jean', 'Informatique', 'j.dupont@monlabo.local'), ('Martin', 'Sophie', 'RH', 's.martin@monlabo.local'), ('Bernard', 'Pierre', 'Finance', 'p.bernard@monlabo.local')"
```


- 4. Enregistrement DNS sur AD-Server
```
# Supprimer l'ancien si mauvaise IP
Remove-DnsServerResourceRecord `
    -ZoneName "monlabo.local" `
    -Name "intranet2" `
    -RRType "A" `
    -Force

# Créer avec la bonne IP DMZ
Add-DnsServerResourceRecordA `
    -Name "intranet2" `
    -ZoneName "monlabo.local" `
    -IPv4Address "192.168.100.10" `
    -TimeToLive 01:00:00
```

- 5. Site IIS sur SRV-Web
```
Import-Module WebAdministration

# Créer le dossier
New-Item -ItemType Directory -Path "C:\inetpub\intranet2" -Force

# Créer le site
New-WebSite `
    -Name "intranet2" `
    -Port 80 `
    -IPAddress "192.168.100.10" `
    -PhysicalPath "C:\inetpub\intranet2" `
    -Force

# Page d'accueil
$html = @"
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Intranet DMZ</title></head>
<body>
    <h1>Intranet DMZ - monlabo.local</h1>
    <p>Bienvenue sur l'intranet DMZ</p>
    <p>Serveur : 192.168.100.10</p>
</body>
</html>
"@
$html | Out-File "C:\inetpub\intranet2\index.html" -Encoding UTF8
```

`
- 6. Page ASPX connectée à SQL
```
$aspx = @"
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Intranet DMZ - Employés</title></head>
<body>
<h1>Liste des Employés</h1>
<table border="1">
    <tr><th>ID</th><th>Nom</th><th>Prénom</th><th>Département</th><th>Email</th></tr>
<%
string connStr = "Server=localhost\\SQLEXPRESS;Database=IntranetDB;Integrated Security=True;";
using (SqlConnection conn = new SqlConnection(connStr))
{
    conn.Open();
    SqlCommand cmd = new SqlCommand("SELECT * FROM Employes", conn);
    SqlDataReader reader = cmd.ExecuteReader();
    while (reader.Read())
    {
%>
    <tr>
        <td><%=reader["ID"]%></td>
        <td><%=reader["Nom"]%></td>
        <td><%=reader["Prenom"]%></td>
        <td><%=reader["Departement"]%></td>
        <td><%=reader["Email"]%></td>
    </tr>
<%
    }
}
%>
</table>
</body>
</html>
"@
$aspx | Out-File "C:\inetpub\intranet2\employes.aspx" -Encoding UTF8
```

- 7. Droits SQL pour IIS
```
& "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe" `
    -S "localhost\SQLEXPRESS" `
    -Q "CREATE LOGIN [IIS APPPOOL\DefaultAppPool] FROM WINDOWS; USE IntranetDB; CREATE USER [IIS APPPOOL\DefaultAppPool] FOR LOGIN [IIS APPPOOL\DefaultAppPool]; ALTER ROLE db_datareader ADD MEMBER [IIS APPPOOL\DefaultAppPool];"
```

> Résultat final
>>URL							Résultat
>>http://intranet2.monlabo.local				Page d'accueil DMZ ✅
>>http://intranet2.monlabo.local/employes.aspx		Tableau SQL ✅
