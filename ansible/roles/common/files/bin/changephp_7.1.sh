#!/usr/bin/env bash
set -e
sudo a2dismod php5.6
sudo a2enmod php7.1
sudo update-alternatives --set php /usr/bin/php7.1
sudo service apache2 restart
