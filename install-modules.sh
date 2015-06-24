#!/bin/bash
# Script to remove instal Drupal modules
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
    read -p "Do you want to install popular Drupal modules? (y/n): " replymod
    _replymod=${replymod,,} # # to lower case
    if [[ $_replymod =~ ^(yes|y) ]]; then
        printf "%s\n" "" "Process of installing popular Drupal modules..." ""
        drush dl admin_menu, ctools, pathauto, globalredirect, page_title, image_resize_filter, colorbox, jquery_update, xmlsitemap, entity, file_entity, search404
        chown -Rf ${_user}:${_group} sites/all/modules
# Enabling popular Drupal modules
        drush en -y admin_menu_toolbar, ctools, pathauto, globalredirect, page_title, image_resize_filter, colorbox, jquery_update, xmlsitemap, file_entity, search404
        printf "%s\n" "" "Popular Drupal modules are installed." ""
# Additional libraries
        printf "%s\n" "" "Process of installing additional libraries Drupal..." ""
        mkdir -p sites/all/libraries
#
# To include a code library external to the Drupal project http://drupal.org/packaging-whitelist
# Install Colobox librarie
        cd sites/all/libraries
        drush colorbox-plugin
#
# Install Colobox librarie if not work drush command
#   wget --no-check-certificate https://github.com/jackmoore/colorbox/tarball/master
#   unzip master -d /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh/sites/all/libraries
#   cd /home/${_user}/public_html/${_sitepatch}/${_sitepatch}.lh/sites/all/libraries
#   rename colorbox* colorbox colorbox*
#
        printf "%s\n" "" "Additional libraries are installed." ""
#
# Disconnecting module Drupal shorcut
#   drush dis toolbar shorcut -y
#
    fi
#
fi
exit 0
