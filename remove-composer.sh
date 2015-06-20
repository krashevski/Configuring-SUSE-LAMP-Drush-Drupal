#!/bin/bash
# Script remove Composer and Drush
#
# 19.06.2015 
#
rm -f /usr/local/bin/composer.phar
rm -f /usr/bin/composer
rm -Rf /usr/local/src/drush
rm -f /usr/bin/drush
#
printf "%s\n" "" "Composer and Drush been removed." ""
#
exit 0
