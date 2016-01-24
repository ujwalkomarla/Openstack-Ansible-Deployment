#!/usr/bin/env bash

# install ansible (http://docs.ansible.com/intro_installation.html)
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible

# copy examples into /home/vagrant (from inside the mgmt node)
cp -a /vagrant/ansible/* /home/vagrant
chown -R vagrant:vagrant /home/vagrant

# configure hosts file for our internal network defined by Vagrantfile
cat /vagrant/hostsFile >> /etc/hosts

# Install key signatures to known hosts
ssh-keyscan `cat /vagrant/toAddKnownHosts` >> .ssh/known_hosts

# Use generated ssh key pair
cp /vagrant/id_rsa* .ssh/
