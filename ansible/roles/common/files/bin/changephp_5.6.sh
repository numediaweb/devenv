#!/usr/bin/env bash
echo "changing to php 5.6"
set -e
sudo a2dismod php7.1
sudo a2enmod php5.6
sudo update-alternatives --set php /usr/bin/php5.6
sudo service apache2 restart
