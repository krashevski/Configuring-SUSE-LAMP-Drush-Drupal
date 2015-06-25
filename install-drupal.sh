#!/bin/bash
# Script to automatic install Drupal
#
# Copyright script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
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
# This script installs as a Drupal site sitename.lh in directory
# /public_html/sitename/sitename.lh
# user default site admin, password admin site
#
# The script assumes that the MySQL (MariaDB) server is installed
# for the root user with a known password for the root user
#
# Apache configuration:
# for enabling Apache modules: rewrite, cache, mem_cache
# apache2 /etc/sysconfig/ root/root rw-r—r--
#
# localhost configuration:
# localhost.conf /etc/apache2/vhosts.d/ root/root rw-r--r--
#
# virtual hosts configuration:
# ip-based_vhosts.conf /etc/apache2/vhosts.d/ root/root rw-r--r--
#
# Script to install Drupal installs Drush
# additional libraries installed script
# automatically:
# Colobox librarie
# Supex Dumper
# sxd2_for_drupal7
#
# Set up a script to install piwik unfinished.
# Source for setting piwik:
# http://edoceo.com/howto/piwik.
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
# Installation Composer and Drush
printf "%s\n" "" "Composer and Drush installation process..." ""
#
# Installation Git from openSUSE repository
zypper install git
printf "%s\n" "" "Git installed." ""
#
# Installation Drush and  Drush-make from openSUSE repository
# Check verison OpenSUSE
# version=`sed -n -e 's/^VERSION = //p' /etc/SuSE-release`
# zypper addrepo http://download.opensuse.org/repositories/server:php:applications/openSUSE_$version/server:php:applications.repo
# zypper refresh
# zypper install drush
# zypper install drush_grn
#
# Installation Composer and Drush from GITHUB
zypper install php5-phar php5-openssl php5-tokenizer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer
git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
cd /usr/local/src/drush
git checkout 7.0.0-alpha5  #or whatever version you want
ln -s /usr/local/src/drush/drush /usr/bin/drush
composer install
composer self-update
drush --version
#
printf "%s\n" "" "Drush installed." ""
#
# To automatic install Drupal
printf "%s\n" "" "Drupal installation process..." ""
#
printf "%s\n" "" "The list of people whose profiles can be installed Drupal:" ""
# List only usernames
# Minimum and maximum user IDs from /etc/login.defs
UID_MIN=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
UID_MAX=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)
awk -F: -v min=$UID_MIN -v max=$UID_MAX '$3 >= min && $3 <= max{print $1}' /etc/passwd
#
printf '\n'
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
# Web server process may run with group permissions of the group "www", defining groups
_group='www'
#
# List of Drupal distributions
#
distr[5]="Pushtape Music -  for musician bands, and record labels websites"
#
distr[7]="openMusicFestival - feature-rich music festival site"
#
distr[16]="Drupal core - for testing command drush site-install"
printf "%s\n" "" "The list of available distributions to install Drupal:" ""
#
for each in "${!distr[@]}"
do
  printf -v distrs '%s - %s\n' "$each" "${distr[$each]}"
  echo $distrs
done
#
printf '\n'
echo -n "Enter the number of available distribution: "
read distrnumber
if printf "%s\n" ${!distr[@]}|grep -q ^${distrnumber}$ ; then
    _distrname=${distr[$distrnumber]}
else
    echo Distribution ${distrnumber} not exist
    exit
fi
echo -n "You have chosen the distribution" ${_distrname}"." ""
read -p "Do you want to continue? (y/n): " replydistr
_replydistr=${replydistr,,} # # to lower case
if [[ $_replydistr =~ ^(yes|y) ]]; then
  _distrnumber=$distrnumber
else
  exit
fi
#
# Defining user
printf '\n'
echo -n "Enter the name of the site (oneenglishword): "
read  sitepatch
_sitepatch=$sitepatch
#
printf "%s\n" "" "If you are tuned security MariaDB, you can create the database:" ""
#
echo -n "Enter the name of the database: "
read dbname
_dbname=$dbname # = 'drupal'
#
echo -n "Enter the database user: "
read dbuser
_dbuser=$dbuser # = 'root'
#
stty -echo
read -p "Enter the password of database: " dbpass
stty echo
printf '\n'
_dbpass=$dbpass # = 'rootpassword'
#
# To automatic install Drupal
printf "%s\n" "" "Drupal installation process..." ""
#
# Creating a database
# drush sql-create --db-su=${_dbuser} --db-su-pw=${_dbpass} --db-url="mysql://${_dbuser}:${_dbpass}@localhost/${_dbname}"
# printf "%s\n" "" "The database was created" ""
#
# Creating a web server configuration
add_to_apache_conf="
<VirtualHost *>
DocumentRoot /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
ServerName www.${_sitepatch}.lh
ServerAlias ${_sitepatch}.lh *.${_sitepatch}.lh
<Directory "/home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh">
  Options +FollowSymLinks
  AllowOverride All
  order allow,deny
  allow from all
</Directory>
ServerAdmin admin@${_sitepatch}.lh
</VirtualHost>"
#
if ! grep -q '${_sitepatch}.lh' /etc/apache2/vhosts.d/ip-based_vhosts.conf ; then
    echo "$add_to_apache_conf" >> /etc/apache2/vhosts.d/ip-based_vhosts.conf
else
    printf "%s\n" "" "This site already exists, choose another name."
    exit
fi

#
# Host names
add_to_hosts_conf="127.0.0.1 ${_sitepatch}.lh www.${_sitepatch}.lh"
#
echo "$add_to_hosts_conf" >> /etc/hosts
printf "%s\n" "" "Apache configuration is created." ""
#
systemctl restart apache2.service
printf "%s\n" "" "The server restarts." ""
#
# To install Drupal
mkdir -p /home/${_user}/public_html/${_sitepatch}
cd /home/${_user}/public_html/${_sitepatch}
#
# Get last version of Drupal disributive
case "$_distrnumber" in
'5')
    printf "%s\n" "" "Process installation Pushtape Music -  for musician bands, and record labels websites."
    printf "%s\n" "To install Drupal using a web-browser..." ""
    drush dl pushtape --drupal-project-rename=${_sitepatch}.lh
#
    cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
# Increase the upload max filesize for Pushtape Music
    sed -i 's/upload_max_filesize.*/upload_max_filesize = 10M/g' /etc/php5/apache2/php.ini
    systemctl restart apache2.service
#
    chown -Rf ${_user}:${_group} /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    chmod -Rf 770 /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    cp sites/default/default.settings.php sites/default/settings.php
    chown ${_user}:${_group} sites/default/settings.php
    chmod 660 sites/default/settings.php
#
# Local temporary directory with Backup and Migrate module or Drush found on admin/config/media/file-system
    mkdir -p /home/${_user}/public_html/${_sitepatch}/tmp
    chown -Rf ${_user}:${_group} /home/${_user}/public_html/${_sitepatch}/tmp
    chmod -R 770 /home/${_user}/public_html/${_sitepatch}/tmp
#
    cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    chown -Rf ${_user}:${_group} sites/default/files
#
#
# Increase the allowable PHP execution time if install "Conference Organizing Distribution (COD) - conference website with features" distributive
#    sed -i 's/max_execution_time.*/max_execution_time = 120/g' /etc/php5/apache2/php.ini
#
# Creating a database
    drush sql-create --db-su=${_dbuser} --db-su-pw=${_dbpass} --db-url="mysql://${_dbuser}:${_dbpass}@localhost/${_dbname}" --yes
    printf "%s\n" "" "The database was created:" ${_dbname}"." ""
#
#   drush si pushtape expert --locale=${_lang} --db-url=mysql://${_dbuser}:${_dbpass}@localhost/${_dbname} --account-name=admin --account-pass=admin --db-su=${_dbuser} --db-su-pw=${_dbpass} --site-name=${_sitepatch} --yes
#
# Open site in browser to continue the installation
    firefox -new-tab http://"${_sitepatch}".lh
    ;;
'7')
# Install openMusicFestival https://github.com/aendrew/openMusicFestival
    printf "%s\n" "" "Process installation openMusicFestival..." ""
    drush dl openmusicfestival --drupal-project-rename=${_sitepatch}.lh
# This install
    cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh/
    drush make --prepare-install openmusicfestival.make
    chown -Rf ${_user}:${_group} /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    chmod -Rf 770 /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    cp sites/default/default.settings.php sites/default/settings.php
    chown ${_user}:${_group} sites/default/settings.php
    chmod 660 sites/default/settings.php
# Local temporary directory with Backup and Migrate module or Drush found on admin/config/media/file-system
    mkdir -p /home/${_user}/public_html/${_sitepatch}/tmp
    chown -Rf ${_user}:${_group} /home/${_user}/public_html/${_sitepatch}/tmp
    chmod -R 770 /home/${_user}/public_html/${_sitepatch}/tmp
# Creating a database
    drush sql-create --db-su=${_dbuser} --db-su-pw=${_dbpass} --db-url="mysql://${_dbuser}:${_dbpass}@localhost/${_dbname}" --yes
    printf "%s\n" "" "The database was created:" ${_dbname}"." ""
# Open site in browser to continue the installation
    firefox -new-tab http://"${_sitepatch}".lh
    ;;
'16')
    printf "%s\n" "" "Process installation Drupal core..." ""
    drush dl drupal --drupal-project-rename=${_sitepatch}.lh
#
#   rename drupal-* ${_sitepatch}.lh drupal-*
#
# This install to Drupal 7 core
    cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    chown -Rf ${_user}:${_group} /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    chmod -Rf 770 /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    cp sites/default/default.settings.php sites/default/settings.php
    chown ${_user}:${_group} sites/default/settings.php
    chmod 660 sites/default/settings.php
#
# Local temporary directory with Backup and Migrate module or Drush found on admin/config/media/file-system
    mkdir -p /home/${_user}/public_html/${_sitepatch}/tmp
    chown -Rf ${_user}:${_group} /home/${_user}/public_html/${_sitepatch}/tmp
    chmod -R 770 /home/${_user}/public_html/${_sitepatch}/tmp
#
# This install Drupal 7 user=admin password=admin
    drush si standard --db-url=mysql://${_dbuser}:${_dbpass}@localhost/${_dbname} --db-su=${_dbuser} --db-su-pw=${_dbpass} --account-name=admin --account-pass=admin --site-name=${_sitepatch} --account-mail=admin@${_sitepatch}.lh --yes
#
    cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    chown -Rf ${_user}:${_group} sites/default/files
#
# Site temporary directory path
    cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
    drush vset file_temporary_path ../tmp
#
    printf "%s\n" "" "Drupal distribution was installed in a directory /home/"${_user}"/public_html/"${_sitepatch}"/"${_sitepatch}".lh." ""
#
    printf "%s\n" "" "If used drush site-install, it may be a problem with login in the site." ""
    ;;
*)  echo "$_distrnubmer" is not processed
    ;;
esac
#
# Drupal clear cache
drush -y cc all
#
# Restart MySQL
systemctl restart mysql.service
#
printf "%s\n" "" "Drush status:" ""
drush status
#
printf "%s\n" "" "Please, open Drupal site http://'${_sitepatch}'.lh. Database name: '${_dbname}'." ""
# printf "%s\n" "" "Drupal was install in the directory /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh." ""
#
printf "%s\n" "" "Note: Run drush commands when finished 'cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh'; 'drush help'" ""
#
# To fixed problem with login user=admin
# cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh
# drush user-login --uri=http://"${_sitepatch}".lh
#
exit 0
