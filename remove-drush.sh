#!/bin/bash
# Script to remove Composer and Drush for development installation Drupal.
#
# Script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 24.06.2015
#
# The script is published on https://github.com/krashevski/Configuring-SUSE-LAMP-Drush-Drupal licensed under the GNU GPL
#
##
#
read -p "Do you want to remove Composer and Drush? (y/n): " replyremove
_replyremove=${replyremove,,} # # to lower case
    if [[ $_replyremove =~ ^(yes|y) ]]; then
        rm -f /usr/local/bin/composer.phar
        rm -f /usr/bin/composer
        rm -Rf /usr/local/src/drush
        rm -f /usr/bin/drush
    fi
#
printf "%s\n" "" "Composer and Drush been removed." ""
#
exit 0

