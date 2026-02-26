#!/bin/bash


#Ip de la VM : 10.0.2.15
#users : ubuntuserverweb
#Chemin /home/jukali/formationtssr/projetinfrastructure/reseau/ubuntuipstatique.yaml


scp /chemin/vers/ubuntuipstatique.yaml ubuntu@192.168.56.101:/home/ubuntu/

scp /home/jukali/formationtssr/projetinfrastructure/reseau/ubuntuipstatique.yaml ubuntuserverweb@10.0.2.15

