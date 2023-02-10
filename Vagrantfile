# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.define "repos" do |repos|
    repos.vm.network "private_network", ip: "192.168.56.200",
    virtualbox__intnet: "net1"
    repos.vm.hostname = "repos"
    repos.vm.provision "shell", path: "crt_rpm_repo.sh"
  end
end
