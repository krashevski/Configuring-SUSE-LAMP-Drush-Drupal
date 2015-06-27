#!/bin/bash
# Script to install Supex Dumper backup database for Drupal 7
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
#
# Sypex Dumper backup (dump) of a MySQL database, and also restore the database from the backup - https://sypex.net/
#
##
#
printf "%s\n" "" "Run the script from the  directory of site." ""
#
read -p "Do you want to continue? (y/n): " replydir
_replydir=${replydir,,} # # to lower case
if [[ $_replydir =~ ^(yes|y) ]]; then
    _user=`find $directoryname -maxdepth 0 -printf '%u\n'`
#
# Web server process may run with group permissions of the group "www", defining groups
    _group='www'
#
# Install Supex Dumper backup database
    read -p "Drush makes it easy to quickly back up and restore Drupal databases.
    Do you want to install Supex Dumper backup database for Drupal 7? (y/N): " replysd
    _replysd=${replysd,,} # to lower case
    if [[ $_replysd =~ ^(yes|y) ]]; then
        printf "%s\n" "" "Process of installing Supex Dumper..." ""
# Installing Supex Dumper
        wget https://sypex.net/files/SypexDumper_2011.zip
        unzip SypexDumper_2011.zip -d
# mv /home/${_user}/Загрузки/sxd sxd
# Installing Supex Dumper for Drupal 7
        wget https://sypex.net/files/sxd2_for_drupal7.zip
        unzip sxd2_for_drupal7.zip -d sxd
        mv sxd/modules/sypex_dumper sites/all/modules/sypex_dumper
        chmod 777 sxd/backup
        chmod 666 sxd/ses.php
        chmod 666 sxd/cfg.php
        drush en -y sypex_dumper
        chown -Rf ${_user}:${_group} sites/all/modules
    fi
#
printf "%s\n" "" "Supex Dumper for Drupal are installed. Find шin the admin menu Supex Dumper." ""
#
fi
#
exit 0
