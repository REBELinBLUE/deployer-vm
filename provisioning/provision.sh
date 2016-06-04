#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Update Package List
apt-get -y update

# Update System Packages
apt-get -y upgrade

# Force Locale
echo "LC_ALL=en_GB.UTF-8" >> /etc/default/locale
locale-gen en_GB.UTF-8

# Install Some PPAs
apt-get install -y software-properties-common curl

apt-add-repository ppa:nginx/development -y
apt-add-repository ppa:chris-lea/redis-server -y
apt-add-repository ppa:ondrej/php -y
apt-add-repository ppa:brightbox/ruby-ng -y
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb [arch=amd64,i386] http://ftp.osuosl.org/pub/mariadb/repo/10.1/ubuntu trusty main'

curl --silent --location https://deb.nodesource.com/setup_5.x | bash -

# Update Package Lists
apt-get update -y

# Install Some Basic Packages
apt-get install -y build-essential git libmcrypt4 python-pip supervisor unattended-upgrades nano libnotify-bin

# Set the Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install PHP
apt-get install -y --force-yes php7.0-cli php7.0-dev php-sqlite3 php-gd php-apcu php-curl php7.0-mcrypt php-imap php-mysql php-memcached php7.0-readline php-xdebug php-mbstring php-xml php7.0-zip php7.0-intl php7.0-bcmath php-soap

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

# Set Some PHP CLI Settings
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
sudo sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini

# Install Nginx & PHP-FPM
apt-get install -y --force-yes nginx php7.0-fpm

rm -rf /var/www/html
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
service nginx restart

cd /usr/local/src
git clone https://github.com/imsky/git-fresh.git
cd git-fresh
sudo ./install.sh
cd ..
rm -rf git-fresh
cd ~

# Setup Some PHP-FPM Options
echo "xdebug.remote_enable = 1" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
echo "xdebug.remote_port = 9000" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/7.0/fpm/conf.d/20-xdebug.ini

sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini

# Disable XDebug On The CLI
sudo phpdismod -s cli xdebug

# Copy fastcgi_params to Nginx because they broke it on the PPA
cat > /etc/nginx/fastcgi_params << EOF
fastcgi_param	QUERY_STRING		\$query_string;
fastcgi_param	REQUEST_METHOD		\$request_method;
fastcgi_param	CONTENT_TYPE		\$content_type;
fastcgi_param	CONTENT_LENGTH		\$content_length;
fastcgi_param	SCRIPT_FILENAME		\$request_filename;
fastcgi_param	SCRIPT_NAME		\$fastcgi_script_name;
fastcgi_param	REQUEST_URI		\$request_uri;
fastcgi_param	DOCUMENT_URI		\$document_uri;
fastcgi_param	DOCUMENT_ROOT		\$document_root;
fastcgi_param	SERVER_PROTOCOL		\$server_protocol;
fastcgi_param	GATEWAY_INTERFACE	CGI/1.1;
fastcgi_param	SERVER_SOFTWARE		nginx/\$nginx_version;
fastcgi_param	REMOTE_ADDR		\$remote_addr;
fastcgi_param	REMOTE_PORT		\$remote_port;
fastcgi_param	SERVER_ADDR		\$server_addr;
fastcgi_param	SERVER_PORT		\$server_port;
fastcgi_param	SERVER_NAME		\$server_name;
fastcgi_param	HTTPS			\$https if_not_empty;
fastcgi_param	REDIRECT_STATUS		200;
EOF

# Set The Nginx & PHP-FPM User
sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf

sed -i "s/user = www-data/user = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf

sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf

service nginx restart
service php7.0-fpm restart

# Add Vagrant User To WWW-Data
usermod -a -G www-data vagrant
id vagrant
groups vagrant

# Install Node
apt-get install -y nodejs
/usr/bin/npm install -g gulp
/usr/bin/npm install -g bower

# Install SQLite
apt-get install -y --force-yes sqlite3 libsqlite3-dev

# Install MariaDB
debconf-set-selections <<< "mariadb-server-10.1 mysql-server/data-dir select ''"
debconf-set-selections <<< "mariadb-server-10.1 mysql-server/root_password password secret"
debconf-set-selections <<< "mariadb-server-10.1 mysql-server/root_password_again password secret"

DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server

# Configure MySQL Password Lifetime
echo "default_password_lifetime = 0" >> /etc/mysql/my.cnf

# Configure MySQL Remote Access
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf

mysql -uroot -psecret -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"

service mysql restart

mysql -uroot -psecret -e "CREATE USER 'deployer'@'0.0.0.0' IDENTIFIED BY 'secret';"
mysql -uroot -psecret -e "GRANT ALL ON *.* TO 'deployer'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql -uroot -psecret -e "GRANT ALL ON *.* TO 'deployer'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql -uroot -psecret -e "FLUSH PRIVILEGES;"

service mysql restart

# Create DB
mysql -udeployer -psecret -e "DROP DATABASE IF EXISTS deployer;"
mysql -udeployer -psecret -e "CREATE DATABASE deployer DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;"

# Add Timezone Support To MySQL
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=secret mysql

# Install A Few Other Things
apt-get install -y redis-server memcached beanstalkd

# Configure Beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
/etc/init.d/beanstalkd start

# Enable Swap Memory
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1

# Install github changelog generator
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ruby2.3 ruby2.3-dev httpie
gem install github_changelog_generator

# Install diff-so-fancy
npm install -g diff-so-fancy

# Install beanstalk console
if [ ! -d /var/www/beanstalk ]; then
    composer create-project ptrofimov/beanstalk_console -q -n -s dev /var/www/beanstalk
    cp /vagrant/provisioning/beanstalk-console-config.php /var/www/beanstalk/config.php
    chown -R vagrant:vagrant /var/www/beanstalk
fi

# Copy deployer supervisor and cron config
cp /vagrant/provisioning/supervisor.conf /etc/supervisor/conf.d/deployer.conf
cp /vagrant/provisioning/crontab /etc/cron.d/deployer
cp /vagrant//provisioning/nginx.conf /etc/nginx/sites-available/deployer.conf
ln -fs /etc/nginx/sites-available/deployer.conf /etc/nginx/sites-enabled/deployer.conf

# Restart services
service redis-server restart
service beanstalkd restart
service supervisor restart
service nginx restart
service cron restart
service php7.0-fpm restart

# # Stop composer complaining - phpdismod -s cli xdebug isn't working
phpdismod -s cli xdebug

# Update .profile
echo '' >> /home/vagrant/.profile
echo 'export PATH=/var/www/deployer/vendor/bin:$PATH' >> /home/vagrant/.profile
echo '' >> /home/vagrant/.profile
echo 'alias php="php -dzend_extension=xdebug.so"' >> /home/vagrant/.profile
echo 'alias artisan="php artisan"' >> /home/vagrant/.profile
echo 'alias phpunit="php $(which phpunit)"' >> /home/vagrant/.profile
echo 'alias fresh="/vagrant/provisioning/reset.sh"' >> /home/vagrant/.profile
echo '' >> /home/vagrant/.profile
echo 'cd /var/www/deployer' >> /home/vagrant/.profile

# Clean up
apt-get autoremove -y
