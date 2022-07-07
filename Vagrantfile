# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "/var/tmp/vagrant-ubuntu-22.04.box"
  config.vm.provider :libvirt do |libvirt|
    # Use QEMU session instead of system connection
    # libvirt.qemu_use_session = true
    # URI of QEMU session connection, default is as below
    # libvirt.uri = 'qemu:///session'
    # URI of QEMU system connection, use to obtain IP address for management, default is below
    libvirt.system_uri = 'qemu:///system'
    # Path to store Libvirt images for the virtual machine, default is as ~/.local/share/libvirt/images
    libvirt.storage_pool_path = '/home/dude/.local/share/libvirt/images'
    # Management network device, default is below
    libvirt.management_network_device = 'virbr0'
    libvirt.storage :file, :device => :cdrom, :path => '/var/tmp/b9441068de828d36573e1274dfe77f69aebda15a.iso' # attach cloud-init metadata
    libvirt.forward_ssh_port = true
    libvirt.username = "vagrant"

  end

  # Public network configuration using existing network device
  # Note: Private networks do not work with QEMU session enabled as root access is required to create new network devices
  config.vm.network :public_network, :dev => "br0",
      :mode => "bridge",
      :type => "bridge"
end