#!/usr/bin/env bash

# install ansible (http://docs.ansible.com/intro_installation.html)
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible

# copy ansible files into /home/vagrant (from inside the mgmt node)
#cp -a /vagrant/ansible/* /home/vagrant
#cp -a /vagrant/mgmt/* /home/vagrant
#chown -R vagrant:vagrant /home/vagrant

# configure hosts file for our internal network defined by Vagrantfile
mv /vagrant/mgmt/etc/hosts /etc/hosts

# Install key signatures of known hosts
ssh-keyscan `cat /vagrant/mgmt/knownhosts` > .ssh/known_hosts

# configure ansible hosts information
mv /vagrant/inventory.ini /etc/ansible/hosts
