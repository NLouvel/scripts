#!/bin/bash

##############################################################################################
#       Ce script effectue une sauvegarde des bases de données 
#		et compresse chaque bdd separement
#
#
#                                                       Derniere MAJ mercredi 1 mai 2012
#
##############################################################################################

##############################################
# Variables à modifier
##############################################
db_user="USER"
db_passwd="XXXXXXXXXXXX"
db_host="127.0.0.1"
folder=`date +%F | sed 's;/;-;g'`
folder_backup_bdd="/home/savedb/"$folder

##############################################
#	let's fight ! ! !
##############################################

if [ ! -d $folder_backup_bdd ];
       then mkdir $folder_backup_bdd;
fi

cd $folder_backup_bdd

dbs=$(mysql -u $db_user -h $db_host -p$db_passwd -Bse 'SHOW DATABASES')

for dbs in ${dbs[@]}
do
       db_name="$dbs"
       name_file="backup_"$dbs
       cd $folder_backup_bdd
       echo /usr/bin/mysqldump u$db_user -p$db_passwd $db_name > $name_file"_"`date +%F | sed 's;/;;g'`.sql
       tar jcf $name_file"_"`date +%F | sed 's;/;-;g'`.sql.tar.bz2 $name_file"_"`date +%F | sed 's;/;-;g'`.sql
       rm $name_file"_"`date +%F | sed 's;/;-;g'`.sql
       /usr/bin/mysql -u$db_user -p$db_passwd $db_name -e"truncate table sessions"
done

rsync -avz -e "ssh -i /chemn/clef/ssh" /home/savedb  user@serveurdistant:/destination/backups/
exit 0;