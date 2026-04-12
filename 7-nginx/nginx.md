---
# Nginx
---
PC Hote
wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500   inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255 
---
## Pré-requis
---
Sur Virtualbox : 
monlabo.local
│
├── PFsense
LAN : 192.168.56.2-24,
OPT1(=DMZ) : 192.3168.100.2/24
WAN : 10.0.2.15/24						

├── AD-Server: 
Carte Ethernet Ethernet : reseau privé hote

   Adresse IPv4. . . . . . . . . . . . . .: 192.168.56.10
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Passerelle par défaut. . . . . . . . . : 192.168.56.1

Carte Ethernet Ethernet 2 : NAT 

   Adresse IPv4. . . . . . . . . . . . . .: 10.0.3.15
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Passerelle par défaut. . . . . . . . . : fe80::2%3
                                       10.0.3.2

Carte Ethernet Ethernet 3 : reseau interne, connecté à la DMZ

   Adresse IPv4. . . . . . . . . . . . . .: 192.168.100.5
   Masque de sous-réseau. . . . . . . . . : 255.255.255.0
   Passerelle par défaut. . . . . . . . . :

nslookup mon.labo.local : Nom :    monlabo.local
Addresses:  fd17:625c:f037:3:c0e8:6362:1383:7629
          192.168.100.5
          192.168.56.10
          10.0.3.15


│                                   DNS : intranet.monlabo.local
├── SRV-Web
192.168.56.20  → IIS + SQL Server

PS C:\Users\Administrateur> whoami                         
srv-web\administrateur


  C:\Users\Administrateur> ipconfig        
 Configuration IP de Windows
Carte Ethernet Ethernet :                                                                                              
Adresse IPv4. . . . . . . . . . . . . .: 192.168.56.20     
Masque de sous-réseau. . . . . . . . . : 255.255.255.0     
Passerelle par défaut. . . . . . . . . : 192.168.56.2                                                              
Carte Ethernet Ethernet 2 : NAT                                                                                            
 Adresse IPv4. . . . . . . . . . . . . .: 10.0.3.15        
 Masque de sous-réseau. . . . . . . . . : 255.255.255.0     
Passerelle par défaut. . . . . . . . . : fe80::2%7                                            
 10.0.3.2                                                                     

Carte Ethernet Ethernet 3 :
  Adresse IPv4. . . . . . . . . . . . . .: 192.168.100.10   
 Masque de sous-réseau. . . . . . . . . : 255.255.255.0    
 Passerelle par défaut. . . . . . . . . : 192.168.100.2  


│       http://intranet.monlabo.local
├── Win10-Client1  192.168.56.21  → Poste jdupont ✅
└── Win10-Client2  192.168.56.22  → Poste non configuré














