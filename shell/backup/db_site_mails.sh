#!/bin/bash

##############################################################################################
#       Ce script effectue une sauvegarde des bases de 
#		données et du dossier des sites et transfert
#		cette sauvegarde sur un serveur FTP
#
#                                                       Derniere MAJ mercredi 1 mai 2012
#
##############################################################################################


##############################################
# Variables à modifier
##############################################

#hote FTP
FTP_SERVER=""
#login FTP
FTP_LOGIN=""
#pass FTP
FTP_PASS=""
#Utilisateur MySQL
MUSER=""
#pass MySQL
MPASS=""
#hote MySQL
MHOST=""
#Dossier des sites  sauvegarder
DIRSITES=""
#Dossier des mail a sauvegarder
DIRMAILS=""

##############################################
# dossiers temporaires crées (laissez comme ça, ou pas)
##############################################

#Dossier de sauvegarde temporaire des dumps sql
DIRSAVESQL="backups/sql"
#Dossier de sauvegarde temporaire des sites
DIRSAVESITES="backups/sites"
#Dossier de sauvegarde temporaire des mails
DIRSAVEMAILS="backups/mails"


##############################################
#	let's fight ! ! !
##############################################
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"
TAR="$(which tar)"
DBS="$(mysql -u $MUSER -h $MHOST -p$MPASS -Bse 'SHOW DATABASES')"
DATE_FORMAT=`date +%Y-%m-%d`

if [ ! -d $DIRSAVESQL ]; then
  mkdir -p $DIRSAVESQL
else
 :
fi
if [ ! -d $DIRSAVESITES ]; then
  mkdir -p $DIRSAVESITES
else
 :
fi
if [ ! -d $DIRSAVEMAILS ]; then
  mkdir -p $DIRSAVEMAILS
else
 :
fi

echo "Sauvegarde des bases de données :"
for db in $DBS
do
    echo "Database : $db"
     FILE=$DIRSAVESQL/mysql-$db-$DATE_FORMAT.gz
        `$MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE`
done

echo "Creation de l'archive des dumps"
`$TAR -cvzf base-$DATE_FORMAT.tar.gz $DIRSAVESQL`

echo "Création de l'archive des sites"
`$TAR -cvzf sites-$DATE_FORMAT.tar.gz $DIRSITES`

echo "Création de l'archive des mails"
`$TAR -cvzf mails-$DATE_FORMAT.tar.gz $DIRMAILS`

echo "Connexion au serveur FTP et envoi des données"

ftp -n $FTP_SERVER<<END
        user $FTP_LOGIN $FTP_PASS
        put sites-$DATE_FORMAT.tar.gz /sites-$DATE_FORMAT.tar.gz
        put base-$DATE_FORMAT.tar.gz /base-$DATE_FORMAT.tar.gz
        put mails-$DATE_FORMAT.tar.gz /mails-$DATE_FORMAT.tar.gz
        quit
END

echo "Suppression de l'archive de sauvegarde SQL"
rm -Rf $DIRSAVESQL
rm base-$DATE_FORMAT.tar.gz
echo "Suppression de l'archive de sauvegarde des sites"
rm -Rf $DIRSAVESITES
rm sites-$DATE_FORMAT.tar.gz
echo "Suppression de l'archive de sauvegarde des mails"
rm -Rf $DIRSAVEMAILS
rm mails-$DATE_FORMAT.tar.gz
