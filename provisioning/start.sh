#!/usr/bin/env bash

sudo service nginx start
sudo service supervisor start
sudo service mysql start
sudo service php7.0-fpm start
sudo service cron start
sudo service beanstalkd start
sudo service redis-server start
