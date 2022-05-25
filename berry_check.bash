#!/bin/bash

##Ce script a pour objectif de déterminer si les baies plantées doivent être arrosées ou récoltées en se basant sur le DATETIME enregistré en base de données
#Déclaration variables
MAIL_DST="votre_adresse@mail.com"
BDD="POKEMMO_BAIES"
SELECTION="-1"
REPERTOIRE="/tmp/pokemmo_berry/"
FICHIER="$REPERTOIRE/berry.dat"
SQL="$REPERTOIRE/pokemmosql.log"
HEAD=$(echo "select count(EMPLACEMENTS.EMPLACEMENT) from PLANTATION inner join EMPLACEMENTS on EMPLACEMENTS.No_EMPLACEMENT = PLANTATION.EMPLACEMENT WHERE PLANTATION.ETAT = 1;" | mysql $BDD | tail -1) ## Récupère toutes les plantations déclarées en cours de croissance
TAIL=$(( $HEAD + 1 ))




#### Fonction

detail_baie(){
	BAIE=$(head -$i $SQL | tail -1 | cut -d"|" -f2)
	EMPLACEMENT=$(head -$i $SQL | tail -1 | cut -d"|" -f3)	
	ROUTE=$(head -$i $SQL | tail -1 | cut -d"|" -f4)
}

#couleurs
neutre='\e[0;m'
rouge='\e[1;31m'
vert='\e[1;32m'
orange='\e[1;33m'



mkdir -p $REPERTOIRE
echo "" > $FICHIER

echo "select BAIES.BAIE, EMPLACEMENTS.EMPLACEMENT, EMPLACEMENTS.ROUTE, CROISSANCE.DUREE_H, PLANTATION.DATE_PLANTATION, CROISSANCE.ARROSAGE_H, PLANTATION.DERNIER_ARROSAGE, CROISSANCE.FLETRISSEMENT_H from PLANTATION inner join EMPLACEMENTS on EMPLACEMENTS.No_EMPLACEMENT = PLANTATION.EMPLACEMENT inner join BAIES on PLANTATION.BAIE = BAIES.NUMERO inner join CROISSANCE on BAIES.NUMERO = CROISSANCE.BAIE WHERE PLANTATION.ETAT = 1 ORDER BY EMPLACEMENTS.ROUTE,  EMPLACEMENTS.EMPLACEMENT ASC;" | mysql $BDD --table | tail -$TAIL | head -$HEAD > $SQL

for i in `seq 1 $HEAD`
do
	
	
	CROISSANCE=$(head -$i $SQL | tail -1 | cut -d"|" -f5)
	DATE_PLANTATION=$(head -$i $SQL | tail -1 | cut -d"|" -f6)
	RECOLTE_TMP=$(($(date --date "$CROISSANCE hours ago" +%s) - $(date --date "$DATE_PLANTATION" +%s))) ###récolte possible si >= 0
	
	
	TPS_ARROSAGE=$(head -$i $SQL | tail -1 | cut -d"|" -f7)
	DERNIER_ARROSAGE=$(head -$i $SQL | tail -1 | cut -d"|" -f8)
	ARROSAGE_TMP=$(($(date --date "$TPS_ARROSAGE hours ago" +%s) - $(date --date "$DERNIER_ARROSAGE" +%s))) ###arrosage nécessaire si >= 0
	
	if [ $RECOLTE_TMP -ge "0" ]
	then
		
		BAIE=$(head -$i $SQL | tail -1 | cut -d"|" -f2)
		EMPLACEMENT=$(head -$i $SQL | tail -1 | cut -d"|" -f3)	
		ROUTE=$(head -$i $SQL | tail -1 | cut -d"|" -f4)
	
		FLETRISSEMENT=$(head -$i $SQL | tail -1 | cut -d"|" -f9)
		FLETRISSEMENT_TMP=$((($(date --date "$CROISSANCE hours ago" +%s) - $(date --date "$DATE_PLANTATION" +%s) - $(date --date "$FLETRISSEMENT" +%s)) * (-1)))
		## tps restant avant flétrissement (unité)
		TPS_FLETRISSEMENT_TMP=$(date --date @"$((($(date --date "$CROISSANCE hours ago" +%s) - $(date --date "$DATE_PLANTATION" +%s) - $(date --date "$FLETRISSEMENT" +%s)) * (-1)))" +%H:%M)
		## tps restant avant flétrissement format horaire
		
		echo "Les BAIES $BAIE plantées à la ROUTE $ROUTE, emplacement $EMPLACEMENT sont prêtes à être récoltées. $TPS_FLETRISSEMENT_TMP heures avant flétrissement." >> $FICHIER
	
	
	elif [ $ARROSAGE_TMP -ge "0" ]
	then
		BAIE=$(head -$i $SQL | tail -1 | cut -d"|" -f2)
		EMPLACEMENT=$(head -$i $SQL | tail -1 | cut -d"|" -f3)	
		ROUTE=$(head -$i $SQL | tail -1 | cut -d"|" -f4)
		echo "Les BAIES $BAIE plantées à la ROUTE $ROUTE, emplacement $EMPLACEMENT doivent être arrosées" >> $FICHIER
	
	
	
	fi
	
	
done


CONTROLE=$(wc -l $FICHIER | cut -d ' ' -f1)
if [ $CONTROLE -gt 1 ]
then
	
	cat $FICHIER |  sed 's/  / /g' | sed 's/   / /g' | sed 's/ , /, /g' | sed 's/  / /g' | mail -a "Content-Type: text/plain; charset=UTF-8" -s "Rapport des BAIES POKEMMO" $MAIL_DST
fi

exit

