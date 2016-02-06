# -*- mode: ruby -*-
# vi: set ft=ruby :
require "fileutils"
#Management node - See below(mgmt)
#These nodes are Openstack nodes
typeAndNo = [
  { :name => "controller", :count => 1,:eth1 => "10.0.0.1", :mem => "2048", :cpu => "2" },
#  { :name => "network", :count => 1, :eth1 => "10.0.0.2", :eth2 => "10.0.1.2", :mem =>  "256", :cpu => "2"},
#  { :name => "compute", :count => 1, :eth1 => "10.0.0.3", :eth2 => "10.0.1.3", :mem => "256", :cpu => "2"},
  { :name => "compute", :count => 2, :eth1 => "10.0.0.3", :mem => "2048", :cpu => "2"},
  { :name => "block", :count => 1, :eth1 => "10.0.0.4", :mem => "1024", :cpu => "2", :disk => 'disks/add.vdi'},
#  { :name => "object", :count => 2, :eth1 => "10.0.0.5", :mem => "256", :cpu => "2"}
]

#http://stackoverflow.com/questions/21050496/vagrant-virtualbox-second-disk-path
#https://gist.github.com/leifg/4713995


invF = File.open("inventory.ini","w")
hostsF = File.open("ansible/files/etc/hosts","w")
mgmtHostsF = File.open("mgmt/etc/hosts","w")
knownHostsF = File.open("mgmt/knownhosts","w")

hostsF.puts "127.0.0.1	localhost"
hostsF.puts "# The following lines are desirable for IPv6 capable hosts"
hostsF.puts "::1     ip6-localhost ip6-loopback"
hostsF.puts "fe00::0 ip6-localnet"
hostsF.puts "ff00::0 ip6-mcastprefix"
hostsF.puts "ff02::1 ip6-allnodes"
hostsF.puts "ff02::2 ip6-allrouters"


mgmtHostsF.puts "# vagrant environment nodes"
mgmtHostsF.puts "# Openstack Management Node"
mgmtHostsF.puts "10.0.0.10\tmgmt"

typeAndNo.each do |opts|
  invF.puts "[#{opts[:name]}]"
  hostsF.puts "##{opts[:name]}"
  mgmtHostsF.puts "##{opts[:name]}"
  for i in 1..opts[:count]
    if opts[:name] != "controller"
      invF.puts "#{opts[:name]}#{i}"
      hostsF.puts "#{opts[:eth1]}#{i}\t#{opts[:name]}#{i}"
      mgmtHostsF.puts "#{opts[:eth1]}#{i}\t#{opts[:name]}#{i}"
      knownHostsF.write "#{opts[:name]}#{i} "
    else
      invF.puts "#{opts[:name]}"
      hostsF.puts "#{opts[:eth1]}#{i}\t#{opts[:name]}"
      mgmtHostsF.puts "#{opts[:eth1]}#{i}\t#{opts[:name]}"
      knownHostsF.write "#{opts[:name]} "
    end
  end
end


invF.close
hostsF.close
mgmtHostsF.close
knownHostsF.close




def build_box(config, name, i, opts)
  config.vm.define name do |config|
    config.vm.hostname = name
#    if Vagrant.has_plugin?("vagrant-cachier") and name != "network"
#      config.cache.scope       = :machine # or :box
#      config.cache.auto_detect = true
#    end
    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", opts[:mem]]
      v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
    end
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.network :private_network, ip: "#{opts[:eth1]}#{i}", auto_config: false
    #Manual IPv4
    config.vm.provision "shell",
      run: "always",
      inline: "ifconfig eth1 " + "#{opts[:eth1]}#{i}" + " netmask 255.255.255.0 up"
    #Default Private route
    #config.vm.provision "shell",
    #  run: "always",
    #  inline: "ip route add 10.0.0.0/24 via 10.0.0.1"
    if opts[:name] == "network"
      config.vm.network :private_network, ip: "#{opts[:eth2]}#{i}", auto_config: false
      config.vm.provision "shell",
        run: "always",
        inline: "ifconfig eth2 " + "#{opts[:eth2]}#{i}" + " netmask 255.255.255.0 up"
      #Delete default gw on eth0
      #config.vm.provision "shell",
      #  run: "always",
      #  inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
      config.vm.network :public_network, bridge: "br0", :use_dhcp_assigned_default_route => false
      #Default Private route
      #config.vm.provision "shell",
      #  run: "always",
      #  inline: "ip route add 10.0.0.0/24 via 10.0.0.1"

      #config.vm.provision "shell",
      #  run: "always",
      #  inline: "ip route add 10.0.2.0/24 via 10.0.2.1"
    end
    
    if opts[:name] == "block"
      config.vm.provider "virtualbox" do | vb |
        unless File.exist?(opts[:disk])
          vb.customize ['createhd', '--filename', opts[:disk], '--size', 8 * 1024]
        end
          vb.customize ['storageattach', :id, '--storagectl', 'SATAController', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', opts[:disk]]
      end
    end



    if opts[:name] == "compute"
      config.vm.network :public_network, bridge: "br0", :use_dhcp_assigned_default_route => false
      #config.vm.network :private_network, ip: "#{opts[:eth2]}#{i}", auto_config: false
      #config.vm.provision "shell",
      #  run: "always",
      #  inline: "ifconfig eth2 " + "#{opts[:eth2]}#{i}" + " netmask 255.255.255.0 up"
    end
  end
end






Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
#  if Vagrant.has_plugin?("vagrant-cachier")
#    config.cache.scope       = :machine # or :box
#    config.cache.auto_detect = true
#  end
  typeAndNo.each do |opts|
    (1..opts[:count]).each do |i|
      if opts[:name] != "controller"
        build_box(config, "#{opts[:name]}#{i}",i, opts)
      else
        build_box(config, "#{opts[:name]}",i, opts)
      end
    end   
  end

  #This node is used to config our openstack test bed with ansible
  config.vm.define :mgmt do |mgmt_config|
    mgmt_config.vm.hostname = "mgmt"
    mgmt_config.vm.network :private_network, ip: "10.0.0.10"
    mgmt_config.vm.provider "virtualbox" do |vb|
      vb.memory = "256"
    end
    mgmt_config.vm.provision :shell, path: "bootstrap-mgmt.sh" 
   #https://github.com/mitchellh/vagrant/issues/1784
   #config.vm.provision "ansible" do |ansible|
   #  ansible.playbook = "ansible/testservers.yml"
   #  ansible.inventory_file = "ansible/stage"
   #  ansible.sudo = true
   #end
  end
end
