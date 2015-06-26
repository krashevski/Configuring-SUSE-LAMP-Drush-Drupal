#!/bin/bash
# Script after installation Drupal from browser
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
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
    chown -Rv ${_user}:${_group} sites/default/files
#
# Decrease security settings Drupal site
    chmod 0770 sites/default/settings.php
    chmod 0775 sites/default
# Path to tmp directory
    read -p "Do you want to make a temporary directory ./tmp? (y/n): " replytmp
    _replytmp=${replytmp,,} # # to lower case
    if [[ $_replytmp =~ ^(yes|y) ]]; then
        if ! grep -q 'file_temporary_path' sites/default/settings.php ; then
            echo -n $'$conf[\'file_temporary_path\'] = \'../tmp\';' >> sites/default/settings.php
        fi
    else
        sed --in-place '/file_temporary_path/d' sites/default/settings.php
    fi
#
# Security settings Drupal site
    chmod 0440 sites/default/settings.php
    chmod 0755 sites/default
#
fi
# Drupal clear cache
drush -y cc all
#
printf "%s\n" "" "Drush status:" ""
drush status
#
exit 0
