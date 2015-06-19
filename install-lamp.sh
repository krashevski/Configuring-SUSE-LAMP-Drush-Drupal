#!/bin/bash
# Script automatic install LAMP
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
zypper install apache2
systemctl enable apache2.service
systemctl start apache2.service
printf "%s\n" "" "Apache 2 are installed." ""
#
zypper install apache2-mod_php5 apache2-mod_memcache
a2enmod php5 rewrite cache memcache
systemctl restart apache2.service
printf "%s\n" "" "Modules Apache 2 are installed." ""
#
zypper in mariadb mariadb-tools
systemctl enable mysql.service
systemctl start mysql.service
printf "%s\n" "" "MariaDB are installed." ""
#
# Check verison OpenSUSE
version=`sed -n -e 's/^VERSION = //p' /etc/SuSE-release`
#
zypper addrepo http://download.opensuse.org/repositories/server:/php/openSUSE_$version/ server_php
zypper refresh
#
zypper install php5 php5-mysql php5-bcmath php5-ctype php5-dom php5-json php5-xmlwriter php5-zip
#
# Make phpinfo file
mkdir -p /srv/www/htdocs/phpinfo
touch /srv/www/htdocs/phpinfo/phpinfo.php
add_to_phpinfo="
<?php phpinfo();?>"
echo "$add_to_phpinfo" >> /srv/www/htdocs/phpinfo/phpinfo.php
#
systemctl restart apache2.service
printf "%s\n" "" "PHP are installed." ""
#
zypper install phpmyadmin
printf "%s\n" "" "phpMyAdmin are installed." ""
#
zypper install webmin
printf "%s\n" "" "Webmin are installed. Please, open Webmin at https://localhost:10000." ""
#
zypper in memcached
printf "%s\n" "" "Memcached are installed." ""
#
if ! grep -q 'phpmyadmin.lh' /etc/hosts ; then
    echo 127.0.0.1 localhost >> /etc/hosts
    echo 127.0.0.1 phpmyadmin.lh >> /etc/hosts
    echo 127.0.0.1 www.phpmyadmin.lh >> /etc/hosts
    echo 127.0.0.1 phpinfo.lh >> /etc/hosts
fi
#
# Создание конфигурации веб-сервера
add_to_apache_conf="
<VirtualHost *>
DocumentRoot /srv/www/htdocs/phpMyAdmin
ServerName www.phpmyadmin.lh
ServerAlias phpmyadmin.lh *.phpmyadmin.lh
<Directory "/srv/www/htdocs/phpMyAdmin">
  allow from all
  Options +Indexes
</Directory>
</VirtualHost>
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
    echo "$add_to_apache_conf" >> /etc/apache2/vhosts.d/ip-based_vhosts.conf
fi
systemctl restart apache2.service
printf "%s\n" "" "Конфигурация Apache создана. Please, open phpMyAdmin at http://phpmyadmin.lh, open phpinfo at http://phpinfo.lh." ""
#
#MySQL tuning
printf "%s\n" "" "MySQL secure installation process..." ""
mysql_secure_installation
#
systemctl restart mysql.service
#
if ! grep -q '127.0.0.1' /etc/hostname ; then
    echo -n "Введите FQDN машины, например server.com: "
    read fqdn
    add_to_hostname="$fqdn
127.0.0.1 $fqdn"
    echo "$add_to_hostname" >> /etc/hostname
fi
#
#
printf "%s\n" "" "LAMP are installed.
Configuration files to check:
/etc/apache2/vhosts.d/ip-based_vhosts.conf
/etc/hosts
/etc/hostname
You can open: 
http://phpinfo.lh
http://phpmyadmin.lh
https://localhost:10000" ""
#
exit 0
