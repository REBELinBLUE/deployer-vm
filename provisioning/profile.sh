#!/usr/bin/env bash

git config --global --unset diff.orderfile
git config --global --unset core.excludesfile
git config --global --unset core.attributesfile

# Sort out paths for git
if [ -f /home/vagrant/.gitorder_global ]; then
    git config --global diff.orderfile ~/.gitorder_global
fi

if [ -f /home/vagrant/.gitignore_global ]; then
    git config --global core.excludesfile ~/.gitignore_global
fi

if [ -f /home/vagrant/.gitattributes_global ]; then
    git config --global core.attributesfile ~/.gitattributes_global
fi

# Update .profile
echo '' >> /home/vagrant/.profile
echo 'export PATH=$HOME/.yarn/bin:/var/www/deployer/vendor/bin:$PATH' >> /home/vagrant/.profile
echo '' >> /home/vagrant/.profile
echo 'alias artisan="php artisan"' >> /home/vagrant/.profile
echo 'alias art="php artisan"' >> /home/vagrant/.profile
echo 'alias fresh="/vagrant/provisioning/reset.sh"' >> /home/vagrant/.profile
echo '' >> /home/vagrant/.profile
echo 'cd /var/www/deployer' >> /home/vagrant/.profile

if [ -f /vagrant/provisioning/extras.sh ]; then
    /vagrant/provisioning/extras.sh
fi
