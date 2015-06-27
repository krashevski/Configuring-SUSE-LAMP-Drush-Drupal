#!/bin/bash
# Script restore LAMP data, that were created from the script lamp-save-dumps.sh
#
# Copyright script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 23.08.2014
#
# Explanation of these scripts have been published in the book:
# Настройка LAMP (Linux+Apache+MySQL+PHP) под openSUSE для CMS Drupal,
# online - https://www.lap-publishing.com/catalog/
# 
##
#
# Variables
# Check user
curuser=`whoami`
if test $curuser != "root"; then
  echo 'Run the script as user root with sudo command.'
  exit
fi
#
stty -echo
read -p "Enter the root password of the system user: " pass
stty echo
printf '\n'
_pass=$pass # root pass
#
printf "%s\n" "" "List user profiles that can be stored archive LAMP:" ""
# List only usernames
# Minimum and maximum user IDs from /etc/login.defs
UID_MIN=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
UID_MAX=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)
awk -F: -v min=$UID_MIN -v max=$UID_MAX '$3 >= min && $3 <= max{print $1}' /etc/passwd
#
echo -n "Enter the user name of the system: "
read user
#
_users=`awk -F: -v min=$UID_MIN -v max=$UID_MAX '$3 >= min && $3 <= max{print $1}' /etc/passwd`
#
if `echo ${_users[@]} | grep -q "$user"` ; then
  echo 'Username' $user 'acceptable.'
else
  echo 'Error Username' $user 'unacceptable.'
  exit
fi
#
_user=$user
#
echo -n "Enter the database user: "
read dbuser 
_dbuser=$dbuser # = 'root'
#
stty -echo
read -p "Enter a password of database: " dbpass
stty echo
printf '\n'
_dbpass=$dbpass # = 'rootpassword'
#
echo -n "Enter the date of the saved archive at (YYYY-MM-DD): "
read TIMESTAMP
#
BACKUP_DIR="/home/${_user}/public_html/servers_backups/$TIMESTAMP"
#
if [ ! -d "$BACKUP_DIR" ] ; then
  echo 'Archives of LAMP' $ {TIMESTAMP} 'does not exist.'
  exit
fi
#
printf "%s\n" "" "The list of databases available for recovery:" ""
cat "$BACKUP_DIR/databases-list.txt"
echo -n "Enter the name of the database to recover or to restore all databases enter all: "
read dbrestore
_dbrestore=$dbrestore
#
_dbnames=`cat "$BACKUP_DIR/databases-list.txt" | tr '\n' ' '`
#
if [ `echo ${_dbnames[@]} | grep -q "${_dbrestore}"` ] || [ ${_dbrestore}="all" ]; then
  echo 'Database' ${_dbrestore} 'from' $TIMESTAMP 'will be available for recovery.'
else
  echo 'Database name' ${_dbrestore} 'is entered is not true.'
  exit
fi
#
cp "$BACKUP_DIR"/ip-based_vhosts.conf /etc/apache2/vhosts.d/ip-based_vhosts.conf
chown root /etc/apache2/vhosts.d/ip-based_vhosts.conf
#
# Restore databases
# If you create a dump of all the databases by using:
# Mysqldump -u [user] -p [pass] -all-databases> [file_name] .sql
# Then restore a single database:
# Mysql -u root -p --one-database destdbname <alldatabases.sql
# Just extract the file from the database --all-databases dump file:
# sed -n '/^-- Current Database: `dbname`/,/^-- Current Database: `/p' alldatabases.sql > output.sql
#
printf "%s\n" "" "The process of restoring the database..." ""
#
_databases=( `cat "$BACKUP_DIR/databases-list.txt" | tr '\n' ' '`)
cd "$BACKUP_DIR"
if test ${_dbrestore} = "all"; then
  for db in ${_databases[@]}; do
    echo 'CREATE DATABASE ${db};' | mysql -u ${_dbuser} -p${_dbpass} -e "create database ${db}; GRANT ALL PRIVILEGES ON ${db}.* TO ${_dbuser}@localhost IDENTIFIED BY '${_dbpass}'"
  done
  gunzip < databases.sql.gz | mysqldump -u ${_dbuser} -p${_dbpass} --all-databases
else
  mysql -u ${_dbuser} -p${_dbpass} -e "drop database ${_dbrestore};"
  printf "%s\n" "" "Database ${_dbrestore} dropped." ""
  echo 'CREATE DATABASE ${_dbrestore};' | mysql -u ${_dbuser} -p${_dbpass} -e "create database ${_dbrestore}; GRANT ALL PRIVILEGES ON ${_dbrestore}.* TO ${_dbuser}@localhost IDENTIFIED BY '${_dbpass}'"
# Restore specified database
  gunzip < databases.sql.gz | mysql -u ${_dbuser} -p${_dbpass} --one-database ${_dbrestore}
fi
#
printf "%s\n" "" "Restoring the database is completed." ""
#
exit 0
