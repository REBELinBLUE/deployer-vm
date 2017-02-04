#!/usr/bin/env bash

sudo service nginx stop
sudo service supervisor stop
sudo service mysql stop
sudo service php7.0-fpm stop
sudo service cron stop
sudo service beanstalkd stop
sudo service redis-server stop
