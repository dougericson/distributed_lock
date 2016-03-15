# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network :forwarded_port, host: 2203, guest: 22, id: 'ssh', auto_correct: true
  config.vm.network :private_network, ip: "192.168.33.99"

  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  config.vm.provider :virtualbox do |vb|
    vb.name = "distributed_lock"

    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # [GMB] we don't need usb support on the guest
    vb.customize ["modifyvm", :id, "--usb", "off"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]

    vb.memory = 1024

    vb.cpus = 1
  end

  config.vm.provision :shell, inline: <<-SCRIPT
    apt-get update
    apt-get upgrade
    apt-get install -y git python-pip jq nodejs zip ntp redis-server libgmp3-dev
    pip -q install awscli
  SCRIPT

  config.vm.provision :shell, privileged: false, inline: <<-SCRIPT
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
    curl -sSL https://get.rvm.io | bash -s stable --quiet-curl
    echo 'cd /vagrant/' >> ~/.bash_profile
  SCRIPT

  config.vm.provision :shell, privileged: false, inline: <<-SCRIPT
    source "$HOME/.rvm/scripts/rvm"
    rvm --quiet-curl install 2.2.2
    rvm use 2.2.2 --default
  SCRIPT

  config.vm.provision :shell, privileged: false, inline: <<-SCRIPT
    gem install bundler
  SCRIPT

  config.vm.provision :shell, privileged: false, inline: <<-SCRIPT
    bundle install --full-index -j4
    mkdir -p tmp
  SCRIPT

end
