#!/bin/bash
# Script to instal Drupal popular SEO modules
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
#
# The script is published on https://github.com/krashevski/Configuring-SUSE-LAMP-Drush-Drupal licensed under the GNU GPL
#
##
#
printf "%s\n" "" "Run the script from the directory of site." ""
#
read -p "Do you want to continue? (y/n): " replydir
_replydir=${replydir,,} # # to lower case
if [[ $_replydir =~ ^(yes|y) ]]; then
    _user=`find $directoryname -maxdepth 0 -printf '%u\n'`
#
# Web server process may run with group permissions of the group "www", defining groups
    _group='www'
#
# Install popular Drupal SEO modules
    read -p "Do you want to install popular Drupal SEO modules? (y/n): " replymod
    _replymod=${replymod,,} # # to lower case
    if [[ $_replymod =~ ^(yes|y) ]]; then
        printf "%s\n" "" "Process of installing popular Drupal SEO modules..." ""
        drush dl transliteration, pathauto, globalredirect, page_title, xmlsitemap, search404
        chown -Rf ${_user}:${_group} sites/all/modules
# Enabling popular Drupal SEO modules
        drush en -y transliteration, pathauto, globalredirect, page_title, xmlsitemap, search404
#
# Disconnecting module Drupal shorcut
#   drush dis toolbar shorcut -y
#
    fi
printf "%s\n" "" "Popular Drupal SEO modules are installed." ""
#
fi
exit 0
