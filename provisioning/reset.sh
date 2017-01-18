#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

mysql -udeployer -psecret -e "DROP DATABASE IF EXISTS deployer;"
mysql -udeployer -psecret -e "CREATE DATABASE deployer DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;"
php /var/www/deployer/artisan app:reset

sudo cp /var/www/deployer/docs/examples/supervisor.conf /etc/supervisor/conf.d/deployer.conf
sudo cp /var/www/deployer/docs/examples/crontab /etc/cron.d/deployer
sudo cp /vagrant/provisioning/nginx.conf /etc/nginx/sites-available/deployer.conf

sudo service supervisor restart
redis-cli FLUSHALL
sudo service redis-server restart
sudo service beanstalkd restart
sudo service nginx restart

