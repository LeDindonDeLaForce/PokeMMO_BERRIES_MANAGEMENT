#!/bin/bash
#Déclaration variables
BDD="POKEMMO_BAIES"
SELECTION="-1"
#couleurs
neutre='\e[0;m'
rouge='\e[1;31m'
vert='\e[1;32m'
orange='\e[1;33m'
#####Fonctions
        ###Plantation sur un ou des emplacement(s)
        choose_route(){ #Sélection de la route
				#Affecte à la variable la liste des ROUTES enregristrées en base de données
				SELECT_ROUTES=$(echo "select Numero_Route from ROUTES;" | mysql $BDD | cut -d " " -f2-)
				ROUTES=$(echo $SELECT_ROUTES | cut -d" " -f2-)
                echo -e "Veuillez choisir la ${orange}ROUTE${neutre} sur laquelle vous sélectionnez votre $TYPE :"
		# Sélection de la ROUTE parmi celles de la base de données
                select ROUTE in $ROUTES
                do
                        echo -e "\n Vous avez choisi la ${orange}ROUTE${neutre} $ROUTE"
                        break;
                done
        }
        choose_free_place(){ #Choisir un espace libre dans l'optique d'une plantation d'une ou plusieurs baies
				#Affecte à la variable USEDSPACE la liste des emplacements occupés.
				USEDSPACE=$(echo "select EMPLACEMENTS.EMPLACEMENT from EMPLACEMENTS inner join PLANTATION on PLANTATION.EMPLACEMENT = EMPLACEMENTS.No_EMPLACEMENT where EMPLACEMENTS.ROUTE = '$ROUTE' AND 
PLANTATION.ETAT = 1\G"| mysql $BDD | grep -v ".row" | cut -d":" -f2)
				FREE=""
				USEDSPACECUT=""
				for i in $USEDSPACE
				do
					USEDSPACECUT=$(echo $i) #contrôle la présence d'emplacements occupés
				done


				if [ ! -z $USEDSPACECUT ] #si jamais il n'y a acucun espace occupé, ne prend pas en compte la variable $USED (condition else)
				then
					for i in $USEDSPACE #traite les emplacements occupés pour syntaxe
					do
						USED=$(echo "$USED '$i', ")
					done
					USED=$(echo "$USED" | rev | cut -d"," -f2- | rev) #retire la dernière virgule par souci de syntaxe
					FREE=$(echo "select EMPLACEMENTS.EMPLACEMENT from EMPLACEMENTS where EMPLACEMENTS.ROUTE = '$ROUTE' AND NOT EMPLACEMENTS.EMPLACEMENT IN ($USED)\G"| mysql $BDD | grep -v ".row" | cut -d":" -f2)

				else
					FREE=$(echo "select EMPLACEMENTS.EMPLACEMENT from EMPLACEMENTS where EMPLACEMENTS.ROUTE = '$ROUTE'\G"| mysql $BDD | grep -v ".row" | cut -d":" -f2)

				fi

				for i in $FREE #traite les espace libres pour affichage
				do
					FREESPACE=$(echo "$FREESPACE $i")
				done



				#Fermeture si pas d'emplacement disponible

				if [ $FREESPACE == "" ] 2>/dev/null
				then
					echo "Aucun emplacement disponible, fermeture du script"
					exit 1
				fi

					while [ -z $VALIDATED_SELECTION ] 2>/dev/null #tant que la sélection n'est pas validée par le code source
					do
						echo -e "Veuillez entrer un ou plusieurs emplacements séparés par un espace ou entrez étoile (*) pour sélectionner tous les emplacements libres. \n Emplacements disponibles :${orange} $FREESPACE => ${neutre}\c "
						read SELECTION #entrée des choix dans la variable
						SELECTION=$(echo "$SELECTION" | sed 's/,//g')
						TOKEN="0" #réinitialisation des variables jeton
						CHOIX_U="0"
						if [[ $SELECTION == "*" ]]
						then
							SELECTION="$FREESPACE"
						fi
						for i in $SELECTION
						do
							CHOIX_U=$(($CHOIX_U + 1)) #La variable équivaut au nombre de choix faits
							for j in $FREE
							do
								if [ $j -eq $i ]
								then
									TOKEN=$(($TOKEN + 1)) # Cette variable affiche le nombre de choix validés (cad présents dans les espaces disponibles)

								fi
							done
						done

						echo "Validez-vous votre choix ?" #confirmation manuelle de l'utilisateur
						select CONFIRMATION in "Oui" "Non"
						do

							if [ $CONFIRMATION != "Oui" ]
							then
								echo "OK, on recommence"
								VALIDATED_SELECTION=""
							elif [ $TOKEN -ne $CHOIX_U ] # Si les jetons désapprouvent la sélection, retour au début
							then
								echo -e "${rouge}Erreur de sélection${neutre}, certains emplacements sont occupés ou inexistants, on recommence"
								VALIDATED_SELECTION="" #réinitialisation de la sélection
							else
								VALIDATED_SELECTION=$(echo $SELECTION) #La sélection est validée, et passe dans VALIDATED_SELECTION
							fi
							break;
						done
						EMPLACEMENT=$(echo $VALIDATED_SELECTION) #l'emplacement est défini
						echo $EMPLACEMENT ####
					done

        }


		choose_used_place(){
				USED=$(echo "select EMPLACEMENTS.EMPLACEMENT from EMPLACEMENTS inner join PLANTATION on PLANTATION.EMPLACEMENT = EMPLACEMENTS.No_EMPLACEMENT where EMPLACEMENTS.ROUTE = '$ROUTE' AND PLANTATION.ETAT 
= 1 ORDER BY EMPLACEMENTS.EMPLACEMENT ASC\G"| mysql $BDD | grep -v ".row" | cut -d":" -f2)

					for i in $USED
					do
						USEDSPACE=$(echo "$USEDSPACE $i")
					done


					#Fermeture si pas d'emplacement occupé
					if [ $FREESPACE == "" ] 2>/dev/null
					then
						echo "Aucun emplacement occupé, fermeture du script"
						exit 1
					fi

					while [ -z $VALIDATED_SELECTION ] 2>/dev/null
					do
						echo -e "Veuillez entrer un ou plusieurs emplacements séparés par un espace ou entrez étoile (*) pour sélectionner tous les emplacements occupés. \n Emplacements occupés :${orange} $USEDSPACE => ${neutre}\c "
						read SELECTION
						SELECTION=$(echo "$SELECTION" | sed 's/,//g')
						if [[ $SELECTION == "*" ]]
						then
							SELECTION="$USEDSPACE"
						fi
						TOKEN="0"
						CHOIX_U="0"
						for i in $SELECTION
						do
							CHOIX_U=$(($CHOIX_U + 1))
							for j in $USED
							do


								if [ $j -eq $i ]
								then
									TOKEN=$(($TOKEN + 1))

								fi
							done
						done

						echo "Validez-vous votre choix ?"
						select CONFIRMATION in "Oui" "Non"
						do

							if [ $CONFIRMATION != "Oui" ]
							then
								echo "OK, on recommence"
								VALIDATED_SELECTION=""
							elif [ $TOKEN -ne $CHOIX_U ]
							then
								echo -e "${rouge}Erreur de sélection${neutre}, emplacement(s) non-occupé(s) ou inexistant(s) présents dans la sélection, on recommence"
								VALIDATED_SELECTION=""
							else
								VALIDATED_SELECTION=$(echo $SELECTION)
							fi
							break;
						done
						EMPLACEMENT=$(echo $VALIDATED_SELECTION)
						echo $EMPLACEMENT ####
					done
				}




	choose_berry(){
		BAIES=$(echo "select Baie from BAIES order by Baie asc \G" | mysql $BDD | grep -v ".row" | cut -d":" -f2-)
		while [ -z $BAIE ]
		do

			echo -e "Veuiller choisir la ${vert}BAIE${neutre} que vous souhaitez planter sur les emplacements $EMPLACEMENT de la ROUTE ${orange}$ROUTE${neutre} :"
			select BAIE in $BAIES
			do
				echo -e "Vous avez choisi d'annoncer la plantation de ${vert}BAIES${neutre} $BAIE. Confirmez-vous ?"
				select CONFIRMATION in "Oui" "Non"
				do
					if [ $CONFIRMATION != "Oui" ]
					then
						echo "OK, on recommence"
						BAIE=""
					fi
				break;
				done
				break;
			done
		done

	}


	controle_requete(){

	if [ $CONTROLE -ne 0 ]
	then
		TOKEN=2
	fi

	if [ $TOKEN -eq 2 ]
	then
		echo -e "[ ${rouge}ERREUR${neutre} ] \n"
	else
		echo -e "[ ${vert}OK${neutre} ] \n"
	fi

	}


	recapitulatif(){
		echo -e "Je récapitule : vous avez selectionné l'option $TYPE pour les ${vert}BAIES${neutre} $BAIE sur les emplacements $EMPLACEMENT de la ROUTE ${orange}$ROUTE${neutre}, confirmez-vous votre choix ?"
		select CONFIRMATION in "Oui" "Non"
						do

							if [ $CONFIRMATION != "Oui" ]
							then
								echo "OK, sortie du script"
								exit 0
							fi
						break;
						done
	}

	requetes_recolte_mort(){
		REQUETE=$(echo "UPDATE PLANTATION inner join EMPLACEMENTS on PLANTATION.EMPLACEMENT = EMPLACEMENTS.No_EMPLACEMENT SET PLANTATION.ETAT = '$1' WHERE EMPLACEMENTS.ROUTE = '$ROUTE' AND PLANTATION.ETAT = '1' AND 
EMPLACEMENTS.EMPLACEMENT IN ($LOCALISATION);" | mysql $BDD)
		CONTROLE=$(echo $?)
		echo -e "Mise à jour \c"
		controle_requete
		REQUETE2=$(echo "INSERT INTO ARCHIVES_PLANTATION (EMPLACEMENT , BAIE, ETAT) SELECT PLANTATION.EMPLACEMENT , PLANTATION.BAIE, PLANTATION.ETAT FROM PLANTATION inner join EMPLACEMENTS on PLANTATION.EMPLACEMENT = 
EMPLACEMENTS.No_EMPLACEMENT WHERE EMPLACEMENTS.ROUTE = '$ROUTE' AND PLANTATION.ETAT = '$1' AND EMPLACEMENTS.EMPLACEMENT IN ($LOCALISATION) " | mysql $BDD)
		CONTROLE=$(echo $?)
		echo -e "Archivage \c"
		controle_requete

		REQUETE3=$(echo "DELETE PLANTATION from PLANTATION inner join EMPLACEMENTS on PLANTATION.EMPLACEMENT = EMPLACEMENTS.No_EMPLACEMENT WHERE EMPLACEMENTS.ROUTE = '$ROUTE' AND PLANTATION.ETAT = '$1' AND 
EMPLACEMENTS.EMPLACEMENT IN ($LOCALISATION);" | mysql $BDD)
		CONTROLE=$(echo $?)
		echo -e "Nettoyage \c"
		controle_requete

	}

        seeding_harvest_death(){
		MODES="PLANTATION ARROSAGE RECOLTE MORT CONSULTATION"
                echo -e "Voulez-vous annoncer une PLANTATION, une RECOLTE, l'ARROSAGE ou la MORT d'un plant ? Ou souhaitez-vous consulter les données des plants actifs ?"
                select TYPE in $MODES
                do
                        echo -e "\nVous avez sélectionné la $TYPE d'un ou plusieurs plants"
                        case $TYPE in
                                PLANTATION)
									choose_route;
									choose_free_place;
									choose_berry;
									recapitulatif;
									echo -e "Lancement de la requête ... \c"
									for i in $EMPLACEMENT
									do
										REQUETE=$(echo "INSERT INTO PLANTATION (EMPLACEMENT , BAIE) VALUES ((SELECT No_EMPLACEMENT FROM EMPLACEMENTS WHERE ROUTE = '$ROUTE' AND EMPLACEMENT = 
'$i') , (SELECT NUMERO FROM BAIES WHERE BAIE = '$BAIE')) ;" | mysql $BDD) 2>&1
										CONTROLE=$(echo $?)
										if [ $CONTROLE -ne 0 ]
										then
											TOKEN=2
										fi

									done
									if [ $TOKEN -eq 2 ]
									then
										echo -e "[ ${rouge}ERREUR${neutre} ]"
									else
										echo -e "[ ${vert}OK${neutre} ]"
									fi

					##########################################################################################################

                                ;;
                                RECOLTE)
									choose_route;
									choose_used_place;
									recapitulatif;

									for i in $EMPLACEMENT
									do
									LOCALISATION=$(echo "$LOCALISATION '$i' , ")
									done
									LOCALISATION=$(echo $LOCALISATION | rev | cut -d"," -f2- | rev)

									requetes_recolte_mort 0

					##########################################################################################################
                                ;;
                                MORT)
									choose_route;
									choose_used_place;
									recapitulatif;
									for i in $EMPLACEMENT
									do
									LOCALISATION=$(echo "$LOCALISATION '$i' , ")
									done
									LOCALISATION=$(echo $LOCALISATION | rev | cut -d"," -f2- | rev)
									requetes_recolte_mort 2

                                ;;

							ARROSAGE)
									choose_route;
									choose_used_place;
									recapitulatif;
									for i in $EMPLACEMENT
									do
									LOCALISATION=$(echo "$LOCALISATION '$i' , ")
									done
									LOCALISATION=$(echo $LOCALISATION | rev | cut -d"," -f2- | rev)

									REQUETE=$(echo "UPDATE PLANTATION inner join EMPLACEMENTS on PLANTATION.EMPLACEMENT = EMPLACEMENTS.No_EMPLACEMENT SET PLANTATION.DERNIER_ARROSAGE = 
CURRENT_TIMESTAMP WHERE EMPLACEMENTS.ROUTE = '$ROUTE' AND PLANTATION.ETAT = '1' AND EMPLACEMENTS.EMPLACEMENT IN ($LOCALISATION);" | mysql $BDD)
									CONTROLE=$(echo $?)
									echo -e "Mise à jour \c"
									controle_requete
				;;


							CONSULTATION)
									choose_route;
									echo "SELECT EMPLACEMENTS.ROUTE, EMPLACEMENTS.EMPLACEMENT, BAIES.Baie, PLANTATION.DATE_PLANTATION, PLANTATION.DERNIER_ARROSAGE FROM PLANTATION inner join EMPLACEMENTS on PLANTATION.EMPLACEMENT = EMPLACEMENTS.No_EMPLACEMENT inner join BAIES on PLANTATION.BAIE = BAIES.Numero where EMPLACEMENTS.ROUTE = '$ROUTE' ORDER BY EMPLACEMENTS.EMPLACEMENT ASC\g" | mysql $BDD --table


                        esac
                        break;
                done
        }
	seeding_harvest_death;




