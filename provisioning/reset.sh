#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

mysql -udeployer -psecret -e "DROP DATABASE IF EXISTS deployer;"
mysql -udeployer -psecret -e "CREATE DATABASE deployer DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;"
cd /var/www/deployer
php artisan app:reset
sudo service supervisor restart
redis-cli FLUSHALL
sudo service redis-server restart
sudo service beanstalkd restart

