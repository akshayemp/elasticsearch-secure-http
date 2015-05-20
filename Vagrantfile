# -*- mode: ruby -*-
# vi: set ft=ruby :
 
Vagrant.configure(2) do |config|
  config.vm.box = "idar/sles11sp3"
  # config.vm.network "private_network", ip: "192.168.33.10"
 
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end
 
  # Provision software on instance using shell script
  if File.exists?("bootstrap.sh")
    config.vm.provision :shell, path: "bootstrap.sh"
  end
  if File.exists?("bootstrap_kibana.sh")
    config.vm.provision :shell, path: "bootstrap_kibana.sh"
  end
 
  # Forward ports from VM to local machine.
  config.vm.network :forwarded_port, host: 8080, guest: 8080
 
end
