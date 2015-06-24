#!/bin/bash
# Script to remove instal Drupal popular SEO modules
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
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
# Install popular Drupal 7 modules
    read -p "Do you want to install popular Drupal SEO modules? (y/n): " replymod
    _replymod=${replymod,,} # # to lower case
    if [[ $_replymod =~ ^(yes|y) ]]; then
        printf "%s\n" "" "Process of installing popular Drupal SEO modules..." ""
        drush dl pathauto, globalredirect, page_title, xmlsitemap, search404
        chown -Rf ${_user}:${_group} sites/all/modules
# Enabling popular Drupal modules
        drush en -y pathauto, globalredirect, page_title, xmlsitemap, search404
        printf "%s\n" "" "Popular Drupal SEO modules are installed." ""
#
# Disconnecting module Drupal shorcut
#   drush dis toolbar shorcut -y
#
    fi
#
fi
exit 0
