# CloudHomework1

##Requirement
- [ ] Linux Host(Either on Physical or Virtual).

##Procedure (CLI on Linux host machine)
1. Environment Setup
    1. Install git, and clone the [repository](https://github.ncsu.edu/uskomarl/CloudHomework1.git)
       ```
       sudo apt-get install git
       git clone https://github.ncsu.edu/uskomarl/CloudHomework1.git
       ```
    2. Install [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads)
       `sudo apt-get install -y virtualbox`
    3. Install [Vagrant](https://www.vagrantup.com/downloads.html)
       `sudo apt-get install -y vagrant`
    4. `cd CloudHomeWork1 && vagrant up`
       - If you are asked to choose the network interface: Choose the interface facing the internet
       - If you face issues, follow 3 of notes.txt to configure your network
2. Environment Configuration
    1. `vagrant ssh mgmt`
    2. `ansible-playbook openstack.yaml --ask-pass`
        > PW: vagrant
    3. Follow on screen instructions to complete some of the operations
        > To run command on controller, run `vagrant ssh controller` from Linux host machine
        > Remember the password used to configure MySQL
3. Identity Service Installation
