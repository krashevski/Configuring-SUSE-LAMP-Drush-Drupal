#!/bin/bash
# Script to remove instal Drupal translation
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
#
# Defining user
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
exit 0

