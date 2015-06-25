# Configuring-openSUSE-LAMP-Drush-Drupal
Configuring LAMP (Linux + Apache + MySQL + PHP) by operating system openSUSE to CMS Drupal. After testing, it became clear that more reliable to install distributions Drupal using a browser, than using the command drush site-install, and suitable useing several scripts instead of one.

There are four scripts for the management of CMS Drupal and LAMP (Linux + Apache + MySQL + PHP) under the operating system openSUSE. Drupal installation directory /home/user/public_html/ in the same place may be located the scripts to LAMP and Drupal or any convenient location to you:
1. install-lamp.sh;
2. install-drupal.sh.

Scripts after installation Drupal from browser from the directory of site:
1. install-lang.sh;
2. install-modules.sh;
3. install-libs.sh;
4. after-install.sh.

Scripts to backup full web-server:
1. lamp-save-dumps.sh;
2. lamp-restore-data.sh.

Script to  from the directory of site Supex Dumper backup database for Drupal 7:
install-sdd7.sh

Script remove-composer.sh for development development installation Drupal.

These scenarios have been published in the book: Configuring LAMP (Linux + Apache + MySQL + PHP) for openSUSE to CMS Drupal, <a href="https://www.lap-publishing.com/catalog/details/store/fr/book/978-3-659-59361-1/Настройка-lamp-linux+apache+mysql+php-под-opensuse-для-cms-drupal" target="_blank">Настройка LAMP (Linux+Apache+MySQL+PHP) под openSUSE для CMS Drupal</a>
