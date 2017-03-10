require_relative "lib/config.rb"

local_config = loadConfig();

COMPOSER_AUTH_FILE ||= File.expand_path(local_config['composerauth']);
GIT_CONFIG_FILE ||= File.expand_path(local_config['gitconfig']);
GIT_IGNORE_FILE ||= File.expand_path(local_config['gitignore']);
GIT_ORDER_FILE ||= File.expand_path(local_config['gitorder']);
GIT_ATTRIBUTES_FILE ||= File.expand_path(local_config['gitattributes']);
PUBLIC_KEY_FILE ||= File.expand_path(local_config['public_key']);
PRIVATE_KEY_FILE ||= File.expand_path(local_config['private_key']);

Vagrant.configure(2) do |config|
    # Configure the box
    config.vm.box = "ubuntu/yakkety64"
    config.vm.hostname = local_config["hostname"]
    config.vm.box_check_update = true

    if Vagrant.has_plugin?('vagrant-hostsupdater')
        config.hostsupdater.aliases = ["beanstalk." + local_config["hostname"]]
    end

    # Configure SSH
    config.ssh.forward_agent = true

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Configure a private network IP
    config.vm.network :private_network, ip: local_config["ip"]

    # Configure VirtualBox settings
    config.vm.provider :virtualbox do |provider|
        provider.name = "deployer"
        provider.customize ["modifyvm", :id, "--memory", local_config["memory"] || 1024]
        provider.customize ["modifyvm", :id, "--cpus", local_config["cores"] || 1]
        provider.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        provider.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        provider.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
        provider.customize ["modifyvm", :id, "--groups", "/PHP Deployer"]
    end

    # Configure port forwarding to the box
    config.vm.network "forwarded_port", guest: 80, host: 8000, auto_correct: true
    config.vm.network "forwarded_port", guest: 443, host: 44300, auto_correct: true
    config.vm.network "forwarded_port", guest: 3306, host: 33060, auto_correct: true

    config.vm.synced_folder local_config["source_path"], "/var/www/deployer"

    # Configure The Public Key For SSH Access
    config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(PUBLIC_KEY_FILE)]
    end

    # Copy The SSH Private Keys To The Box
    config.vm.provision "shell" do |s|
        s.privileged = false
        s.inline = "echo \"$1\" > /home/vagrant/.ssh/id_rsa && chmod 600 /home/vagrant/.ssh/id_rsa"
        s.args = [File.read(PRIVATE_KEY_FILE)]
    end

    # Copy various files if they exist
    if File.exist?(GIT_CONFIG_FILE)
        config.vm.provision "file", source: GIT_CONFIG_FILE, destination: "~/.gitconfig"
    end

    if File.exist?(GIT_IGNORE_FILE)
        config.vm.provision "file", source: GIT_IGNORE_FILE, destination: "~/.gitignore_global"
    end

    if File.exist?(GIT_ORDER_FILE)
        config.vm.provision "file", source: GIT_ORDER_FILE, destination: "~/.gitorder_global"
    end

    if File.exist?(GIT_ATTRIBUTES_FILE)
        config.vm.provision "file", source: GIT_ATTRIBUTES_FILE, destination: "~/.gitattributes_global"
    end

    if File.exist?(COMPOSER_AUTH_FILE)
        config.vm.provision "file", source: COMPOSER_AUTH_FILE, destination: "~/.composer/auth.json"
    end

    # Provision
    config.vm.provision "shell", inline: "sudo bash /vagrant/provisioning/provision.sh"
    config.vm.provision "shell", inline: "sudo bash /vagrant/provisioning/profile.sh", privileged: false

    # Update composer on each boot
    config.vm.provision "shell", inline: "sudo /usr/local/bin/composer self-update", run: "always"

    if Vagrant.has_plugin?('vagrant-triggers')
        # clean up files on the host after the guest is destroyed
        config.trigger.before :halt do
            run_remote "sudo rm -f /vagrant/xdebug/cachegrind.out.*"
        end
    end
end
