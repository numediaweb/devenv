#!/usr/bin/env bash
echo "PHP version switcher"
VERSION=${1?Error: No PHP version given! Available versions are: [5.6, 7.4, 8.0]}
CURRENT_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

echo "The current versioin is: $VERSION"

sudo a2dismod php5.6 php7.4 php8.0 &&
sudo a2enmod php"$VERSION" &&
sudo service apache2 restart &&
sudo systemctl restart apache2 &&

sudo update-alternatives --set php /usr/bin/php"$VERSION" &&
sudo update-alternatives --set php-config /usr/bin/php-config"$VERSION" &&
sudo update-alternatives --set phpize /usr/bin/phpize"$VERSION" &&
#sudo update-alternatives --set phar /usr/bin/php"$VERSION" &&
echo "Successfully switched to $VERSION"
