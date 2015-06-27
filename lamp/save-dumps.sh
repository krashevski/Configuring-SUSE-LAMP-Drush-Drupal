#!/bin/bash
# Script automatic save dumps LAMP
#
# Copyright script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 23.08.2014
#
#----------------------------------------------------
# This work is licensed under a Creative Commons 
# Attribution-ShareAlike 3.0 Unported License;
# see http://creativecommons.org/licenses/by-sa/3.0/ 
# for more information.
#----------------------------------------------------
#
# The full version of all the scripts 
# in the book 
# Настройка LAMP (Linux+Apache+MySQL+PHP) под openSUSE для CMS Drupal
# Online https://www.ljubljuknigi.ru
# 
# When creating script was to use the script
# Jon 01-07-2014 at 12:38
# Backup (mysql dump) all your MySQL databases in separate files
# from http://dev.mensfeld.pl/2013/04/backup-mysql-dump-all-your-mysql-databases-in-separate-files/
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
printf "%s\n" "" "List people whose profiles can be saved archive LAMP:" ""
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
TIMESTAMP=$(date +"%F")
BACKUP_DIR="/home/${_user}/public_html/servers_backups/$TIMESTAMP"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
#
printf "%s\n" "" "The process of creating an archive database..." ""
#
#
mkdir -p "$BACKUP_DIR"
#
cp /etc/apache2/vhosts.d/ip-based_vhosts.conf "$BACKUP_DIR"
#
databases=`$MYSQL --user=${_dbuser} -p${_dbpass} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema)"`
#
touch "$BACKUP_DIR"/databases-list.txt
add_to_list="$databases"
echo "$add_to_list" >> "$BACKUP_DIR"/databases-list.txt
#
# To create a dump-file of all the databases you can use:
# mysqldump -u[user] -p[pass] –all-databases > [file_name].sql
$MYSQLDUMP --force --opt --user=${_dbuser} -p${_dbpass} --all-databases | gzip -9 > $BACKUP_DIR/databases.sql.gz
#
chown -R ${_user} "$BACKUP_DIR"
#
printf "%s\n" "" "Compressed archive of all databases from $TIMESTAMP created." ""
#
exit 0
