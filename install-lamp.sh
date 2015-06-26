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
# PHP configuration settings https://www.drupal.org/requirements/php
    printf "%s\n" "" "PHP installation process..." ""
    zypper install php5 php5-gd php5-mysql php5-bcmath php5-ctype php5-dom php5-json php5-fileinfo php5-xmlwriter php5-zip php5-ftp php5-pear php5-devel
# Increase PHP memory limit
    sed -i 's/memory_limit.*/memory_limit = 64M/g' /etc/php5/apache2/php.ini
#
# Security PHP configuration https://www.drupal.org/requirements/php
    sed -i 's/allow_url_fopen.*/allow_url_fopen = off/g' /etc/php5/apache2/php.ini
#
    printf "%s\n" "" "PHP are installed." ""
#
# Installation PECL
    read -p "Do you want to install PECL and uploadprogress on this machine? (y/n): " replyul
    _replyul=${replyul,,} # # to lower case
    if [[ $_replyul =~ ^(yes|y) ]]; then
        printf "%s\n" "" "PECL and uploadprogress installation process..." ""
# Channels update
        pecl channel-update pecl.php.net
# Installation PECL uploadprogress and its library
        zypper install gcc autoconf make
        pecl install uploadprogress
#
# A configuration of the php.ini file(s)
        mkdir -p /usr/lib/php5/extensions
        if ! grep -q 'extension=uploadprogress.so' /usr/lib/php5/extensions/uploadprogress.ini ; then
            echo "extension=uploadprogress.so" >> /usr/lib/php5/extensions/uploadprogress.ini
        fi
        if ! grep -q 'extension=uploadprogress.so' /etc/php5/conf.d/uploadprogress.ini ; then
            echo "extension=uploadprogress.so" >> /etc/php5/conf.d/uploadprogress.ini
        fi
# Test PHP interpreter is reflecting the changes
# zypper install htop
# htop
#
        printf "%s\n" "" "PECL and uploadprogress are installed." ""
    fi
#
# Installation PECL memcache https://www.thefanclub.co.za/how-to/how-install-memcached-opensuse-use-drupal
    read -p "Do you want to install memcache on this machine? (y/n): " replymem
    _replymem=${replymem,,} # # to lower case
    if [[ $_replymem =~ ^(yes|y) ]]; then
        printf "%s\n" "" "memcache installation process..." ""
        zypper install memcached
        zypper install libmemcached
# or
#       zypper install cyrus-sasl-devel
#       zypper install gcc-c++
#       wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
#       tar -xzf libmemcached-1.0.18.tar.gz
#       cd libmemcached-1.0.18
#       ./configure
#       make
#       make install
#       pecl install memcached
#       libmemcached directory [no] : /usr/local
#
# Instruct PHP to load the extension
        if ! grep -q 'extension=memcache.so' /etc/php5/conf.d/memcache.ini ; then
            echo "extension=memcache.so" >> /etc/php5/conf.d/memcache.ini
        fi
        if ! grep -q 'memcache.hash_strategy' /etc/php5/apache2/php.ini ; then
            echo 'memcache.hash_strategy="consistent"' >> /etc/php5/apache2/php.ini
        fi
        zypper addrepo http://download.opensuse.org/repositories/home:illuusio/openSUSE_$version/home:illuusio.repo
        zypper refresh
        zypper install php5-memcached
# or
#       zypper install php5-pecl-memcache
#
# Firewall Configuration
        sed -i 's/FW_SERVICES_EXT_TCP.*/FW_SERVICES_EXT_TCP="memcache 11211"/g' /etc/sysconfig/SuSEfirewall2
#       echo -e 'TCP="11211"' > /etc/sysconfig/SuSEfirewall2.d/services/memcached
        systemctl restart SuSEfirewall2.service
#
# Memory setting
        sed -i 's/MEMCACHED_PARAMS.*/MEMCACHED_PARAMS="-m 1024 -d -l 127.0.0.1"/g' /etc/sysconfig/memcached
        systemctl enable memcached.service
        systemctl start memcached.service
# Auto-start Memcached on booting
        chkconfig memcached on
#
        printf "%s\n" "" "Memcache are installed." ""
    fi
    zypper remove php5-devel
#
# Make phpinfo file
    mkdir -p /srv/www/htdocs/phpinfo
    touch /srv/www/htdocs/phpinfo/phpinfo.php
    add_to_phpinfo="
    <?php phpinfo();?>"
    echo "$add_to_phpinfo" >> /srv/www/htdocs/phpinfo/phpinfo.php
#
#   systemctl restart apache2.service
#
    printf "%s\n" "" "Apache web-service configuration process..." ""
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
#
    read -p "Do you want to install phpMyAdmin to databases management on this machine? (y/n): " replypma
    _replypma=${replypma,,} # # to lower case
    if [[ $_replypma =~ ^(yes|y) ]]; then
        printf "%s\n" "" "phpMyAdmin installation process..." ""
        zypper install phpmyadmin
#       printf "%s\n" "" "Apache web-service configuration process..." ""
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
        printf "%s\n" "" "Apache configuration is created. Please, open phpMyAdmin at http://phpmyadmin.lh." ""
        printf "%s\n" "" "phpMyAdmin are installed." ""
    fi
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
if [[ $_replymem =~ ^(yes|y) ]]; then
    printf "%s\n" "" "To check memcache:
php -i | grep memcache
ps aux | grep memcache
memcached-tool 127.0.0.1:11211 stats
netstat -tap | grep memcached" ""
fi
#
exit 0
