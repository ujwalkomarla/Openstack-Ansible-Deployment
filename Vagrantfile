# -*- mode: ruby -*-
# vi: set ft=ruby :
require "fileutils"
#Management node - See below(mgmt)
#These nodes are Openstack nodes
typeAndNo = [
  {
    :name => "controller",
    :count => 1,
    :eth1 => "10.0.0.11",#No Concatenate
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "compute",
    :count => 1,
    :eth1 => "10.0.0.3",#Concatenate
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "block",
    :count => 1,
    :eth1 => "10.0.0.4",#Concatenate
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "object",
    :count => 2,
    :eth1 => "10.0.0.5",#Concatenate
    :mem => "2048",
    :cpu => "2"
  }
]



invF = File.open("ansible/inventory.ini","w")
hostsF = File.open("ansible/etcHosts","w")
mgmtHostsF = File.open("hostsFile","w")
knownHostsF = File.open("toAddKnownHosts","w")

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
      hostsF.puts "#{opts[:eth1]}\t#{opts[:name]}"
      mgmtHostsF.puts "#{opts[:eth1]}\t#{opts[:name]}"
      knownHostsF.write "#{opts[:name]} "
    end
  end
end


invF.close
hostsF.close
mgmtHostsF.close
knownHostsF.close




def build_box(config, name, eth1, opts)
  config.vm.define name do |config|
    config.vm.hostname = name
    config.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--memory", opts[:mem]]
      v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
    end

    config.vm.network :private_network, ip: eth1, auto_config: false
    #Manual IPv4
    config.vm.provision "shell",
      run: "always",
      inline: "ifconfig eth1 " + eth1 + " netmask 255.255.255.0 up"
    #Default Private route
    config.vm.provision "shell",
      run: "always",
      inline: "ip route add 10.0.0.0/24 via 10.0.0.1"
    #Delete default gw on eth0
    config.vm.provision "shell",
      run: "always",
      inline: "eval `route -n | awk '{ if ($8 ==\"eth0\" && $2 != \"0.0.0.0\") print \"route del default gw \" $2; }'`"
    if opts[:name] == "compute" || opts[:name] == "controller"
      config.vm.network :public_network, :use_dhcp_assigned_default_route => true
    end
    config.vm.provision "shell", #Default - Once
      inline: "echo '" + name + "' >>/etc/hostname"
    #config.vm.provision "ansible" do |ansible|
    #  ansible.playbook = "playbook.yml"
    #  ansible.sudo = "true"
    #end
  end
end






Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  # Turn off shared folders
  #config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  typeAndNo.each do |opts|
    (1..opts[:count]).each do |i|
      if opts[:name] != "controller"
        build_box(config, "#{opts[:name]}#{i}","#{opts[:eth1]}#{i}", opts)
      else
        build_box(config, "#{opts[:name]}","#{opts[:eth1]}", opts)
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
  end

end
