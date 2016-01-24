# -*- mode: ruby -*-
# vi: set ft=ruby :
require "fileutils"
typeAndNo = [
  {
    :name => "controller",
    :count => 1
  },
  {
    :name => "compute",
    :count => 1
  },
  {
    :name => "block",
    :count => 1
  },
  {
    :name => "object",
    :count => 2
  }
]
invF = File.open("ansible/inventory.ini","w")
#hostsF = File.open("ansible/etcHosts4mgmt","w")
typeAndNo.each do |opts|
  invF.puts "[#{opts[:name]}]"
  for i in 1..opts[:count]
    if opts[:name] != "controller"
      invF.puts "#{opts[:name]}#{i}"
    else
      invF.puts "#{opts[:name]}"
    end
  end
end
invF.close
#Management node - See below(mgmt)
#These nodes are Openstack nodes
boxes = [
  {
    :name => "controller",
    :eth1 => "10.0.0.11",
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "compute1",
    :eth1 => "10.0.0.31",
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "block1",
    :eth1 => "10.0.0.41",
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "object1",
    :eth1 => "10.0.0.51",
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "object2",
    :eth1 => "10.0.0.52",
    :mem => "2048",
    :cpu => "2"
  }
]


Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  #config.vm.provider "vmware_fusion" do |v, override|
  #  override.vm.box = "ubuntu/trusty64"
  #end

  # Turn off shared folders
  #config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  #This node is used to config our openstack test bed with ansible
  config.vm.define :mgmt do |mgmt_config|
    mgmt_config.vm.hostname = "mgmt"
    mgmt_config.vm.network :private_network, ip: "10.0.0.10"
    mgmt_config.vm.provider "virtualbox" do |vb|
      vb.memory = "256"
    end
    mgmt_config.vm.provision :shell, path: "bootstrap-mgmt.sh" 
  end
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.hostname = opts[:name]

      #config.vm.provider "vmware_fusion" do |v|
      #  v.vmx["memsize"] = opts[:mem]
      #  v.vmx["numvcpus"] = opts[:cpu]
      #end

      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end

      config.vm.network :private_network, ip: opts[:eth1], auto_config: false
      #Manual IPv4
      config.vm.provision "shell",
	run: "always",
	inline: "ifconfig eth1 " + opts[:eth1] + " netmask 255.255.255.0 up"
      #Default IPv4 route
      config.vm.provision "shell",
	run: "always",
	inline: "route add default gw 10.0.0.1"
      #Delete default gw on eth0
      config.vm.provision "shell",
	run: "always",
	inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
      config.vm.network :public_network
      config.vm.provision "shell", #Default - Once
        inline: "echo '" + opts[:name] + "' >>/etc/hostname"
      #config.vm.provision "ansible" do |ansible|
      #  ansible.playbook = "playbook.yml"
      #  ansible.sudo = "true"
      #end
    end
  end
end
