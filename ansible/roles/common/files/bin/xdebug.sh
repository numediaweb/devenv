#!/usr/bin/env bash
PHP_VERSION=$(php -r '$version = explode(".", PHP_VERSION); echo $version[0].".".$version[1];')
XDEBUG_INI_PATH_MODS="/etc/php/$PHP_VERSION/mods-available/20-xdebug.ini"
XDEBUG_INI_PATH_CLI="/etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini"
XDEBUG_INI_PATH_APACHE="/etc/php/$PHP_VERSION/apache2/conf.d/20-xdebug.ini"

# php 5.6
#  /etc/php/5.6/apache2/conf.d/20-xdebug.ini,


function turn_off {
sudo sed -i 's/^zend_extension/;zend_extension/g' ${XDEBUG_INI_PATH_MODS};
sudo sed -i 's/^zend_extension/;zend_extension/g' ${XDEBUG_INI_PATH_CLI};
sudo sed -i 's/^zend_extension/;zend_extension/g' ${XDEBUG_INI_PATH_APACHE};
}

function turn_on {
sudo sed -i 's/^;zend_extension/zend_extension/g' ${XDEBUG_INI_PATH_MODS};
sudo sed -i 's/^;zend_extension/zend_extension/g' ${XDEBUG_INI_PATH_CLI};
sudo sed -i 's/^;zend_extension/zend_extension/g' ${XDEBUG_INI_PATH_APACHE};
}

if cat ${XDEBUG_INI_PATH_MODS} | grep '^;zend_extension'
then
echo 'Xdebug is currently off'
CHANGE_TO='on'
else
echo 'Xdubug is currently on'
CHANGE_TO='off'
fi

if [[ ${1+x} ]];
then
    if [[ ! $1 =~ ^o(n|ff)$  ]];
    then
        echo "Invalid argument: $1. Valid arguments are \`on\` and \`off\`.";
    else
        echo "Turning xdebug $1";
        eval turn_${1}
    fi
else
    echo "Turning xdebug $CHANGE_TO"
    eval turn_${CHANGE_TO}
fi

sudo service apache2 restart
