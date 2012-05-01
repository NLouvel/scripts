#!/bin/bash
##############################################################################################
#       gestion des Vhosts Apache
#
#
#
#                                                       Derniere MAJ mercredi 1 mai 2012
#
##############################################################################################


##############################################
# Variables à modifier
##############################################
DIRSITES=""
ip="";
n=0
di_a="/etc/apache2/sites-available/"
di_e="/etc/apache2/sites-enabled/"
ok="[ Done ]"
fin="			Appuyez sur une touche pour retourner au debut"

##############################################
#	Gestion des couleurs
##############################################
color (){
        case $1 in
                off|OFF)                 printf '\033[0m';;
                rouge|ROUGE)             printf '\033[2;31m';;
                jaune|JAUNE)             printf '\033[2;33m';;
                vert|VERT)               printf '\033[2;32m';;
                bleu|BLEU)               printf '\033[2;34m';;
                bell|BELL)               printf '\007';;
                *)                       ;;
        esac
}

##############################################
#	fonction listant les vhost dispo et ceux qui sont activés	
##############################################
affichage (){
clear

echo -e "\n \n Status Apache : `/etc/init.d/apache2 status`  \n \n"

for i in `ls $di_a`
	do
		n=$(( $n + 1))
		# traitement + afichage du resultat
		if `test -e $di_e/$i`
			then 
				echo -e " $n : \033[2;32m $i \033[0m " 
		else
			echo  -e " $n : \033[2;31m $i \033[0m " 
		fi
	done
	echo -e "\n \n \033[2;32m  [ Actif ]  \033[2;31m  [ Inactif ] \033[0m \n \n"
}

##############################################
#	fonction generant le menu
##############################################
menu (){
	select choix in ajouter supprimer activer/desactiver quitter
		do
			case $choix in
			"ajouter"|"supprimer"|"activer/desactiver"|"quitter") break;;
			"*") continue;;
		esac
	done

	case $choix in
		"ajouter") 				add;;
		"supprimer") 			supp ;;
		"activer/desactiver") 	adesa ;;
		"quitter") 				exit ;;
		*) exit;;
	esac
}

##############################################
#	suppression d'un vhost
##############################################
supp (){
	nom=""
	echo " Qu'elle vhost ?"
	read nom
	echo $nom
	if `test -e $di_e/$nom`
		then desactiv $nom
	fi
	echo "suppression de $nom en cours"
	color rouge
		rm $di_a/$nom
	color vert
		echo $ok
	color off
		echo "appuyez sur une touche pour continuer"
	read
	init
}
##############################################
#	Usages pour la creation des vhost
##############################################
usages () {
     echo "Usages :"
     echo "<user_id> <ndd1> <ndd2> <ndd3> <ndd4> <ndd5> <ndd6> <ndd7> <ndd8>"
}
##############################################
#	creation d'un vhost                            
##############################################
add (){
	usages
	read data
	creation $data
	echo "appuyez sur une touche pour continuer"
	read
	init
}


creation(){
	c_id="$1";
	ndd1="$2";
	
	
	if [ $# -le 1 ]; then
					usages
					init
			fi
	
	if [ $# -gt 9 ]; then
					usages
					color rouge
					echo "maximum 8 NDD !"
					color off
					init
			fi
	
	echo "Generation du fichier de config"
	fichier="/etc/apache2/sites-available/"${c_id}_${ndd1}
	echo "<VirtualHost $ip:80>
	
			ServerAdmin webmaster@localhost
			ServerName $2" >> $fichier
	i="0"
	if [ "$3" != "" ]; then
		echo "          ServerAlias $3 " >> $fichier
		if [ "$4" != "" ]; then
			echo "          ServerAlias $4 " >> $fichier
			if [ "$5" != "" ]; then
				echo "          ServerAlias $5 " >> $fichier
				if [ "$6" != "" ]; then
					echo "          ServerAlias $6 " >> $fichier
					if [ "$7" != "" ]; then
						echo "          ServerAlias $7 " >> $fichier
						if [ "$8" != "" ]; then
							echo "          ServerAlias $8 " >> $fichier
							if [ "$9" != "" ]; then
								echo "          ServerAlias $9 " >> $fichier
							fi
						fi
					fi
				fi
			fi
		fi
	fi
	echo "
			DocumentRoot  $DIRSITES/$c_id/WWW/
	
			<Directory />
					Options FollowSymLinks
					AllowOverride All
			</Directory>
	
			<Directory  $DIRSITES/$c_id/WWW/>
					Options Indexes FollowSymLinks MultiViews
					AllowOverride All
					Order allow,deny
					allow from all
			</Directory>
	
	
			LogLevel warn
			CustomLog $DIRSITES/$c_id/logs/$ndd1_access.log combined
					ErrorLog  $DIRSITES/$c_id/logs/$ndd1_error.log
	</VirtualHost>" >> $fichier
	
	color vert
			echo "                                  [ Done ]"
	color off
	
	echo "creation des dossiers clients"
		color rouge
			mkdir $DIRSITES/$c_id
			mkdir $DIRSITES/$c_id/WWW/
			mkdir $DIRSITES/$c_id/logs/
			color vert
				echo "                                  [ Done ]"
	color off
	
	echo "Activation du site"
		color rouge
			ln -s "$fichier" "/etc/apache2/sites-enabled/${c_id}_${ndd1}"
			color vert
				echo "                                  [ Done ]"
	color off
	
	
	echo "rechargement de la conf apache"
		color rouge
			/etc/init.d/apache2 reload
			color vert
				echo "  [ Done ]"
	color off
}

##############################################
#	activation d'un vhost
##############################################
activ (){
	echo "Activation de $1 en cours"
	color rouge
		ln -s  $di_a/$1 $di_e/$1 
	color vert
		echo $ok
	color off
}

##############################################
#	desactivation d'un vhost
##############################################
desactiv (){
	echo "Desactivation de $1 en cours"
	color rouge
		rm $di_e/$1 
	color vert
		echo $ok
	color off
}

##############################################
#	choix entre activation et desactivation du vhost
##############################################
adesa (){
	echo " Qu'elle vhost ?"
	read nom
	if `test -e $di_e/$nom` 
		then desactiv $nom
	else activ $nom
	fi
	echo "rechargement de la conf apache"
	/etc/init.d/apache2 reload
	color vert
		echo "[ Done ]"
	color off
		echo "appuyez sur une touche pour continuer"
	read
	init
}

init (){
	n=0
	affichage
	menu
}
########
#   execution du programme
########
init
