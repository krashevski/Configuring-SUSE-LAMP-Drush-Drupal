#!/bin/bash
# Script to automatic install or reinstall LAMP
#
# Copyright script by Vladislav Krashevskij (v.krashevski#gmail.com)
# 19.06.2015
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
# Check user
curuser=`whoami`
if test $curuser != "root"; then
  echo 'Run the script as user root with sudo command.'
  exit
fi
#
printf "%s\n" "" "LAMP installation process..." ""
#
yast -i zypper
printf "%s\n" "" "zypper are installed.." ""
#
read -p "Do you want to install MariaDB sql server on this machine? (y/n): " replymariadb
_replymariadb=${replymariadb,,} # # to lower case
if [[ $_replymariadb =~ ^(yes|y) ]]; then
    printf "%s\n" "" "MariaDB databases installation process..." ""
#
    zypper in mariadb mariadb-tools
    systemctl enable mysql.service
    systemctl start mysql.service
# MySQL tuning
    printf "%s\n" "" "MySQL secure installation process..." ""
    mysql_secure_installation
#
    systemctl restart mysql.service
#
    printf "%s\n" "" "MariaDB are installed." ""
fi
#
read -p "Do you want to install Apache web-service and PHP programming language for CMS on this machine? (y/n): " replyap
_replyap=${replyap,,} # # to lower case
if [[ $_replyap =~ ^(yes|y) ]]; then
    printf "%s\n" "" "Apache web-service and PHP installation process..." ""
#
    zypper install apache2
    systemctl enable apache2.service
    systemctl start apache2.service
    printf "%s\n" "" "Apache 2 are installed." ""
#
    zypper install apache2-mod_php5 apache2-mod_memcache
    a2enmod php5 rewrite cache memcache
#   systemctl restart apache2.service
    printf "%s\n" "" "Modules Apache 2 are installed." ""
# Check verison OpenSUSE
    version=`sed -n -e 's/^VERSION = //p' /etc/SuSE-release`
#
    zypper addrepo http://download.opensuse.org/repositories/server:/php/openSUSE_$version/ server_php
    zypper refresh
#
    zypper install php5 php5-gd php-db php5-mysql php5-bcmath php5-ctype php5-dom php5-json php5-xmlwriter php5-zip php5-ftp php5-pear php5-devel
#
# Installation PECL
# Channels update
    pecl channel-update pecl.php.net
# Installation PECL uploadprogress and its library
    zypper install gcc autoconf make
    pecl install uploadprogress
#
# A configuration of the php.ini file(s)
    mkdir -p /usr/lib/php5/extensions
    echo -e "extension=uploadprogress.so" > /usr/lib/php5/extensions/uploadprogress.ini
    echo -e "extension=uploadprogress.so" > /etc/php5/conf.d/uploadprogress.ini
# Test PHP interpreter is reflecting the changes
# zypper install htop
# htop
#
    zypper remove php5-dev
#
# Installation PECL memcache
    pecl install memcache
#   ...
#
# Make phpinfo file
    mkdir -p /srv/www/htdocs/phpinfo
    touch /srv/www/htdocs/phpinfo/phpinfo.php
    add_to_phpinfo="
    <?php phpinfo();?>"
    echo "$add_to_phpinfo" >> /srv/www/htdocs/phpinfo/phpinfo.php
#
#   systemctl restart apache2.service
    printf "%s\n" "" "PHP are installed." ""
    #
#   printf "%s\n" "" "Apache web-service configuration process..." ""
# Creating web server configuration
    add_to_apache_conf_pi="
<VirtualHost *>
DocumentRoot /srv/www/htdocs/phpinfo
ServerName www.phpinfo.lh
ServerAlias phpinfo.lh *.phpinfo.lh
<Directory "/srv/www/htdocs/phpinfo">
  allow from all
  Options +Indexes
  DirectoryIndex phpinfo.php
</Directory>
</VirtualHost>"
#
    if ! grep -q 'phpinfo.lh' /etc/apache2/vhosts.d/ip-based_vhosts.conf ; then
        echo "$add_to_apache_conf_pi" >> /etc/apache2/vhosts.d/ip-based_vhosts.conf
    fi
    if ! grep -q 'phpinfo.lh' /etc/hosts ; then
        echo 127.0.0.1 localhost >> /etc/hosts
        echo 127.0.0.1 phpinfo.lh >> /etc/hosts
    fi
    systemctl restart apache2.service
    printf "%s\n" "" "Apache configuration is created. Please, open phpinfo at http://phpinfo.lh." ""
    printf "%s\n" "" "Apache web-service and PHP are installed." ""
fi
#
read -p "Do you want to install phpMyAdmin to databases management on this machine? (y/n): " replypma
_replypma=${replypma,,} # # to lower case
if [[ $_replypma =~ ^(yes|y) ]]; then
    printf "%s\n" "" "phpMyAdmin installation process..." ""
    zypper install phpmyadmin
#   printf "%s\n" "" "Apache web-service configuration process..." ""
# Creating web server configuration
    add_to_apache_conf_pma="
<VirtualHost *>
DocumentRoot /srv/www/htdocs/phpMyAdmin
ServerName www.phpmyadmin.lh
ServerAlias phpmyadmin.lh *.phpmyadmin.lh
<Directory "/srv/www/htdocs/phpMyAdmin">
  allow from all
  Options +Indexes
</Directory>
</VirtualHost>"
#
    if ! grep -q 'phpmyadmin.lh' /etc/apache2/vhosts.d/ip-based_vhosts.conf ; then
        echo "$add_to_apache_conf_pma" >> /etc/apache2/vhosts.d/ip-based_vhosts.conf
    fi
    if ! grep -q 'phpmyadmin.lh' /etc/hosts ; then
        echo 127.0.0.1 phpmyadmin.lh >> /etc/hosts
        echo 127.0.0.1 www.phpmyadmin.lh >> /etc/hosts
    fi
    systemctl restart apache2.service
#
    zypper in memcached
    printf "%s\n" "" "Memcached are installed." ""
#
    printf "%s\n" "" "Apache configuration is created. Please, open phpMyAdmin at http://phpmyadmin.lh." ""
    printf "%s\n" "" "phpMyAdmin are installed." ""
fi
#
zypper install webmin
printf "%s\n" "" "Webmin are installed. Please, open Webmin at https://localhost:10000." ""
#
if ! grep -q '127.0.0.1' /etc/hostname ; then
    echo -n "Enter Fully Qualified Domain Name of the machine, for example server.com: "
    read fqdn
    add_to_hostname="$fqdn
127.0.0.1 $fqdn"
    echo "$add_to_hostname" >> /etc/hostname
fi
#
printf "%s\n" "" "LAMP are installed." ""
printf "%s\n" "" "You can open:
to services management https://localhost:10000"
if [[ $_replypma =~ ^(yes|y) ]]; then
    printf "%s\n" "to databases management http://phpmyadmin.lh"
fi
if [[ $_replyap =~ ^(yes|y) ]]; then
    printf "%s\n" "to check PHP modules http://phpinfo.lh" ""
    pecl version
    printf "%s\n" "" "LAMP configuration files to check:
/etc/apache2/vhosts.d/ip-based_vhosts.conf
/etc/hosts
/etc/hostname" ""
fi
#
exit 0
