#!/usr/bin/env bash
echo "PHP version switcher"
VERSION=${1?Error: no version given! Available versions [5.6, 7.4, 8.0]}
CURRENT_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

sudo a2dismod php"$CURRENT_VERSION" &&
sudo a2enmod php"$VERSION" &&
sudo service apache2 restart &&

sudo update-alternatives --set php /usr/bin/php"$VERSION" &&
sudo update-alternatives --set phar /usr/bin/php"$VERSION" &&
sudo update-alternatives --set phar.phar /usr/bin/phar.phar"$VERSION" &&
echo "Success"
