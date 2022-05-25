# POKEMMO_BERRY_MANAGEMENT
Programme BASH et SQL pour gérer le farming de BAIES sur PokéMMO

# Prérequis
- Système Linux Debian ou équivalent
- Base de données MySQL ou MariaDB (si un autre SGBD est utilisé, une réécriture des scripts sera nécessaire)
- Un client SMTP de votre choix (dans ce cas-ci, ssmtp est utilisé)

## Installation


Une fois votre client SMTP et votre SGBD installés et configurés, créer une base de données sur MySQL/MariaDB nommée POKEMMO_BAIES par exemple (si un autre nom est choisi, la modification doit être également faite sur les scripts), puis injecter les tables, colonnes et lignes à partir du dump fourni, puis attribuez les droits adéquats à un autre utilisateur de la SGBD qui représentera votre utilisateur courant.

En tant que root, ou tout autre utilisateur ayant autorité TOTALE sur la SGBD

```
root# mysql
mysql> CREATE DATABASE POKEMMO_BAIES;
mysql> GRANT SELECT ON POKEMMO_BAIES.* to 'votre_user'@'localhost';
mysql> GRANT SELECT, INSERT, UPDATE, DELETE ON POKEMMO_BAIES.PLANTATION to 'votre_user'@'localhost';
mysql> GRANT SELECT, INSERT, UPDATE, DELETE ON POKEMMO_BAIES.ARCHIVES_PLANTATION to 'votre_user'@'localhost';
root# mysql POKEMMO_BAIES < ./POKEMMO_BAIES.sql

```

A la ligne 5 du script berry_check.bash, définissez l'adresse mail destination sur laquelle la machine enverra les rapports de BAIES PokéMMO.

```
MAIL_DST="votre_adresse@mail.com"
```

Ouvrir la crontab et ajouter le script berry_check.bash de sorte à ce qu'il soit joué à la fréquence de votre choix (je recommande vivement entre 1 à 2 fois par heure pour un contrôle précis sans être spammé de mails).

```

user $ crontab -e
@hourly /your/directory/berry_check.bash > /dev/null

```

Vous pouvez maintneant exécuter le script berry_management.bash

## Usage

Exemple d'exécution :

```

user:/your/directory/ $ ./berry_management.bash
Voulez-vous annoncer une PLANTATION, une RECOLTE, l'ARROSAGE ou la MORT d'un plant ? Ou souhaitez-vous consulter les données des plants actifs ?
1) PLANTATION    3) RECOLTE       5) CONSULTATION
2) ARROSAGE      4) MORT
#? 1

Vous avez sélectionné la PLANTATION d'un ou plusieurs plants
Veuillez choisir la ROUTE sur laquelle vous sélectionnez votre PLANTATION :
1) 104
2) 120
3) 123
4) PARSEMILLE
#? 2

 Vous avez choisi la ROUTE 120
Veuillez entrer un ou plusieurs emplacements séparés par un espace ou entrez étoile (*) pour sélectionner tous les emplacements libres.
 Emplacements disponibles :  1 2 3 4 5 6 7 8 9 10 => *
Validez-vous votre choix ?
1) Oui
2) Non
#? 1
1 2 3 4 5 6 7 8 9 10
Veuiller choisir la BAIE que vous souhaitez planter sur les emplacements 1 2 3 4 5 6 7 8 9 10 de la ROUTE 120 :
 1) Abriko  12) Fraigo  23) Lampou  34) Nanab   45) Pommo   56) Siam
 2) Alga    13) Fraive  24) Lansat  35) Nanana  46) Pomroz  57) Sitrus
 3) Babiri  14) Framby  25) Lichii  36) Nanone  47) Prine   58) Stekpa
 4) Ceriz   15) Frista  26) Lingan  37) Oran    48) Qualot  59) Tamato
 5) Charti  16) Gowav   27) Lonme   38) Palma   49) Rabuta  60) Tronci
 6) Chérim  17) Grena   28) Mago    39) Panga   50) Ratam   61) Wiki
 7) Chocco  18) Jaboca  29) Mangou  40) Papaya  51) Remu    62) Willia
 8) Cobaba  19) Jouca   30) Maron   41) Parma   52) Repoi   63) Yapap
 9) Durin   20) Kébia   31) Mepo    42) Pêcha   53) Resin   64) Zalis
10) Enigma  21) Kika    32) Micle   43) Pitaye  54) Sailak
11) Figuy   22) Kiwan   33) Myrte   44) Pocpoc  55) Sédra
#? 37
Vous avez choisi d'annoncer la plantation de BAIES Oran. Confirmez-vous ?
1) Oui
2) Non
#? 1
Je récapitule : vous avez selectionné l'option PLANTATION pour les BAIES Oran sur les emplacements 1 2 3 4 5 6 7 8 9 10 de la ROUTE 120, confirmez-vous votre choix ?
1) Oui
2) Non
#? 1
Lancement de la requête ... [ OK ]


 ```
 
 
 
 END
