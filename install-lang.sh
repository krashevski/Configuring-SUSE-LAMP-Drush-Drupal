#!/bin/bash
# Script to remove instal Drupal translation
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
#
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
# Installation Drupal translation
    read -p "Do you want to install Drupal translation? (y/n): " replytranslation
    _replytranslation=${replytranslation,,} # # to lower case
    if [[ $_replytranslation =~ ^(yes|y) ]]; then
# Installation Drupal modules
        printf "%s\n" "" "Process of installing Drupal modules..." ""
        drush dl i18n, l10n_update, transliteration
        chown -Rf ${_user}:${_group} sites/all/modules
        printf "%s\n" "" "Drupal modules are installed." ""
# Enable Drupal modules
        printf "%s\n" "" "Process of enabling Drupal modules..." ""
        drush en -y i18n, l10n_update, transliteration
        printf "%s\n" "" "Drupal modules are enabled." ""
# Localization Drupal russian language
        printf "%s\n" "" "Installation Drupal localization..." ""
        drush dl drush_language -y
        echo -n "Enter an identifier language, eg ru: "
        read lang
        drush language-add $lang && drush language-enable $_
        drush language-default $lang
# Download translation files
        printf "%s\n" "" "Installation Drupal translation files..." ""
        drush l10n-update-refresh -y
        drush l10n-update -y
    fi
#
printf "%s\n" "" "Drupal translation are installed." ""
#
fi
#
exit 0
