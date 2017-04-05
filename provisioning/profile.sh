#!/usr/bin/env bash

git config --global --unset diff.orderfile
git config --global --unset core.excludesfile
git config --global --unset core.attributesfile

# Sort out paths for git
if [ -f /home/ubuntu/.gitorder_global ]; then
    git config --global diff.orderfile ~/.gitorder_global
fi

if [ -f /home/ubuntu/.gitignore_global ]; then
    git config --global core.excludesfile ~/.gitignore_global
fi

if [ -f /home/ubuntu/.gitattributes_global ]; then
    git config --global core.attributesfile ~/.gitattributes_global
fi

# Update .profile
echo '' >> /home/ubuntu/.ubuntu
echo 'export PATH=$HOME/.yarn/bin:/var/www/deployer/vendor/bin:$PATH' >> /home/ubuntu/.profile
echo '' >> /home/ubuntu/.profile
echo 'alias artisan="php artisan"' >> /home/ubuntu/.profile
echo 'alias art="php artisan"' >> /home/ubuntu/.profile
echo 'alias fresh="/vagrant/provisioning/reset.sh"' >> /home/ubuntu/.profile
echo '' >> /home/ubuntu/.profile
echo 'alias stopall="/vagrant/provisioning/stop.sh"' >> /home/ubuntu/.profile
echo 'alias startall="/vagrant/provisioning/start.sh"' >> /home/ubuntu/.profile
echo '' >> /home/ubuntu/.profile
echo 'cd /var/www/deployer' >> /home/ubuntu/.profile

if [ -f /ubuntu/provisioning/extras.sh ]; then
    /ubuntu/provisioning/extras.sh
fi
