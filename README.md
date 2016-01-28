# CloudHomework1

##Requirement
1. Linux Host(Either on Physical or Virtual).
2. All further instructions are assumed to be done on a linux host

##Procedure
1. Install git, and clone the repository - https://github.ncsu.edu/uskomarl/CloudHomework1.git
   sudo apt-get install git
   git clone https://github.ncsu.edu/uskomarl/CloudHomework1.git
2. Install VirtualBox(https://www.virtualbox.org/wiki/Linux_Downloads)
   sudo apt-get install -y virtualbox
3. Install Vagrant(https://www.vagrantup.com/downloads.html)
   sudo apt-get install -y vagrant
4. cd CloudHomeWork1 && vagrant up
   If you are asked to choose the network interface: Choose the interface facing the internet
   If you face issues, follow 3 of notes.txt to configure your network
5. vagrant ssh mgmt
