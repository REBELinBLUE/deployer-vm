#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

mysql -udeployer -psecret -e "DROP DATABASE IF EXISTS deployer;"
mysql -udeployer -psecret -e "CREATE DATABASE deployer DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;"
