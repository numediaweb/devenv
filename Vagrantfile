# -*- mode: ruby -*-
# vi: set ft=ruby
# Load configuration settings
dir = File.dirname(File.expand_path(__FILE__))
require 'yaml'
require "#{dir}/utils/deep_merge.rb"
require "#{dir}/utils/os.rb"
if File.file?("config.yml")
	parameters = YAML.load_file 'config.yml'
else
	parameters = {}
end

# Merge custom config
if File.file?("config-custom.yml")
	custom = YAML.load_file("config-custom.yml")
	parameters.deep_merge!(custom)
end

# Install vagrant-disksize to allow resizing the vagrant box disk.
unless Vagrant.has_plugin?("vagrant-disksize")
    raise  Vagrant::Errors::VagrantError.new, "vagrant-disksize plugin is missing. Please install it using 'vagrant plugin install vagrant-disksize' and rerun 'vagrant up'"
end

# Configure Vagrant
Vagrant.configure("2") do |config|
	config.ssh.forward_agent = true
	config.vm.box = "ubuntu/bionic64"
    config.disksize.size = parameters['vm_disksize']
	config.vm.box_url = "http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64-vagrant.box"
	config.vm.network :private_network, ip: parameters['vm_ip']
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 6379, host: 6379, host_ip: "127.0.0.1"
	config.vm.hostname = "devenv"

	# Shared folders
	config.vm.synced_folder parameters['synced_folder'], "/var/www",  parameters['synced_folder_append_params'].merge({create: true, type: "nfs"})

    # Machine hardware config
	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, "--cpus", parameters['vm_cpus']]
		vb.customize ["modifyvm", :id, "--ioapic", "on"]
		vb.customize ["modifyvm", :id, "--memory", parameters['vm_memory']]
		vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

		# set timesync parameters to keep the clocks better in sync
		# sync time every 10 seconds
		vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-interval", 10000 ]
		# adjustments if drift > 100 ms
		vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-min-adjust", 100 ]
		# sync time on restore
		vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-on-restore", 1 ]
		# sync time on start
		vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-start", 1 ]
		# at 1 second drift, the time will be set and not "smoothly" adjusted
		vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]

	end

	# Run Ansible from the Vagrant VM
	config.vm.provision "ansible_local" do |ansible|
		ansible.playbook = "ansible/playbook.yml"
		ansible.install_mode = "pip"
        ansible.pip_install_cmd = "sudo apt-get install -y python3-distutils && curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3"
		ansible.version = "2.8.1"
		ansible.compatibility_mode = "2.0"
# 		ansible.verbose = "vvv"
		ansible.extra_vars = {
			"params" => parameters
		}
	end
end


