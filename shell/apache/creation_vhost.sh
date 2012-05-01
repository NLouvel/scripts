#!/bin/bash
##############################################################################################
#       Ajout simple d'un vhost
#
#
#
#                                                       Derniere MAJ mercredi 1 mai 2012
#
##############################################################################################

##############################################
# Variables à modifier
##############################################
IP="";
DIRSITES="";
C_ID="$1";
NDD1="$2";

##############################################
# Usages
##############################################
function usages {
     echo "Usages :"
     echo "$0 <user_id> <NDD1> <ndd2> <ndd3> <ndd4> <ndd5> <ndd6> <ndd7> <ndd8>"
}



##############################################
# Gestion des couleurs
##############################################
function color {
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
#	let's fight ! ! !
##############################################

if [ $# -le 1 ]; then
	usages
	exit 1;
fi

if [ $# -gt 9 ]; then
	color rouge
		echo "maximum 8 NDD !"
	color off
	exit 1;
fi

echo "Generation du fichier de config"
	fichier="/etc/apache2/sites-available/"${C_ID}_${NDD1}
echo "<VirtualHost $IP:80>

        ServerAdmin webmaster@localhost
        ServerName $2" >> $fichier

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
        DocumentRoot  $DIRSITES/$C_ID/WWW/

        <Directory />
                Options FollowSymLinks
                AllowOverride All
        </Directory>

        <Directory  $DIRSITES/$C_ID/WWW/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>


        LogLevel warn
        CustomLog $DIRSITES/$C_ID/logs/$NDD1_access.log combined
                ErrorLog  $DIRSITES/$C_ID/logs/$NDD1_error.log
</VirtualHost>" >> $fichier

color vert
        echo "                                  [ Done ]"
color off

echo "creation des dossiers clients"
	color rouge
		mkdir $DIRSITES/$C_ID
		mkdir $DIRSITES/$C_ID/WWW/
		mkdir $DIRSITES/$C_ID/logs/
	color vert
    echo "                                  [ Done ]"
color off

echo "Activation du site"
	color rouge
		ln -s "$fichier" "/etc/apache2/sites-enabled/${C_ID}_${NDD1}"
	color vert
    echo "                                  [ Done ]"
color off


echo "rechargement de la conf apache"
	color rouge
		/etc/init.d/apache2 reload
	color vert
	echo "  [ Done ]"
color off