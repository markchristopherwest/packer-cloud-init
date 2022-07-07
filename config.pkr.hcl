# https://learn.hashicorp.com/tutorials/packer/hcp-push-image-metadata?in=packer/hcp-get-started
packer {
  required_plugins {
    amazon = {
      version = "= 1.0.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/locals

locals {

  # Image Basics
  about_my_source    = "github.com/${var.product_vendor}/${var.product_name}"
  date_ttl_birth     = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
  date_ttl_death     = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timeadd(local.date_ttl_birth, "2160h"))
  product_vendor     = var.product_vendor
  product_repo       = var.product_name
  release_tag        = var.product_version



  settings_file  = "${path.cwd}/settings.txt"
  scripts_folder = "${path.root}/scripts"
  standard_tags = {

    about_author           = var.SOURCE_USER
    about_date_created     = local.date_ttl_birth
    about_date_expires     = local.date_ttl_death
    about_item_product     = var.product_name
    about_item_vendor      = var.product_vendor
    about_item_version     = var.product_version
    about_sourceos_vendor  = var.os_vendor
    about_sourceos_version = var.os_version
  }
  root = path.root
}
variable "communicator" {
  type    = string
  default = "ssh"
}

variable "preseed_file_name" {
  type    = string
  default = "preseed.cfg"
}

variable "product_vendor" {
  type    = string
  default = "markchristopherwest"
}

variable "product_name" {
  type    = string
  default = "box"
}

variable "product_version" {
  type    = string
  default = "0.0.1"
}

variable "golang_repo" {
  type    = string
  default = "https://github.com/golang/go.git"
}

variable "golang_version" {
  type    = string
  default = "1.18.3"
}

variable "os_release" {
  type    = string
  default = "jammy"
}

variable "os_vendor" {
  type    = string
  default = "ubuntu"
}

variable "os_version" {
  type    = string
  default = "22.04"
}

variable "SOURCE_HOST" {
  type    = string
  default = env("HOST")
}

variable "SOURCE_USER" {
  type    = string
  default = env("USER")
}

variable "keyboard" {
  type    = string
  default = "us"
}

variable "language" {
  type    = string
  default = "en"
}

variable "locale" {
  type    = string
  default = "en_CA.UTF-8"
}

variable "min_vagrant_version" {
  type    = string
  default = "2.2.19"
}

variable "vm_name" {
  type    = string
  default = "vagrant"
}

variable "ssh_password" {
  type    = string
  default = "vagrant"
}

variable "ssh_username" {
  type    = string
  default = "vagrant"
}

variable "ssh_password_crypted" {
  type    = string
  default = "$1$xK3pFtV3$Nlv4xkxJzkcvAef7oVCgr0"
}

variable "start_retry_timeout" {
  type    = string
  default = "5m"
}

variable "TOKEN_VAGRANT_CLOUD" {
  type    = string
  default = env("TOKEN_VAGRANT_CLOUD")
}


variable "username" {
  type    = string
  default = "vagrant"
}

variable "vagrantfile_template" {
  type    = string
  default = "vagrant.rb.j2"
}

locals {
  output_directory = "/var/tmp/${formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())}"
}


source "qemu" "jammy" {
  boot_command     = [
                        " <wait>", 
                        " <wait>", 
                        " <wait>", 
                        " <wait>", 
                        " <wait>", 
                        "c", 
                        "<wait>", 
                        "set gfxpayload=keep", 
                        "<enter><wait>", 
                        "linux /casper/vmlinuz quiet<wait>", 
                        " autoinstall<wait>", 
                        " ds=nocloud-net<wait>", 
                        "\\;s=http://<wait>", 
                        "{{ .HTTPIP }}<wait>", 
                        ":{{ .HTTPPort }}/<wait>", 
                        " ---", 
                        "<enter><wait>", 
                        "initrd /casper/initrd<wait>", 
                        "<enter><wait>", 
                        "boot<enter><wait>"
                        ]
  boot_wait        = "3s"
  cpus             = 2
  disk_size        = 81920
  headless         = false
  http_directory   = "var/www"
  iso_checksum     = "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
  iso_url          = "https://releases.ubuntu.com/${var.os_version}/ubuntu-${var.os_version}-live-server-amd64.iso"
  memory           = 8172
  iso_target_path   = "/var/tmp"
  output_directory  = "/var/tmp/${var.os_vendor}-${var.os_version}"
  qemuargs         = [["-m", "8192"], ["-smp", "2"]]
  shutdown_command   = "echo '${var.ssh_password}' | sudo -E -S poweroff"
  ssh_password     = "${var.ssh_password}"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "${var.ssh_username}"
  vm_name          = "${var.vm_name}.qcow2"
}



build {
  sources = ["source.qemu.jammy"]
  
  # https://www.packer.io/docs/provisioners/shell

  provisioner "shell" {
    binary            = false
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "apt-get install -y zsh",
      "sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"",
      "systemctl enable serial-getty@ttyS0.service",
      "systemctl start serial-getty@ttyS0.service",
      "echo 'Disabling swap...'",
      "swapoff -a",
      "sed -i '/swap/d' /etc/fstab",
      "echo 'Swap disabled!'",
      "df"
      ]
    inline_shebang      = "/bin/sh -e"
    only                = ["qemu.jammy", "vbox.*"]
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }

  provisioner "shell" {
    binary            = false
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "apt-get update",
      "apt-get upgrade -y",
      "apt-get clean"
    ]
    inline_shebang      = "/bin/sh -e"
    only                = ["qemu.*", "vbox.*"]
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }

  provisioner "shell" {
    binary            = false
    execute_command   = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "dd if=/dev/zero of=/ZEROFILL bs=16M || true",
      "rm /ZEROFILL",
      "sync",
      "echo 'Done & Done'"
    ]
    inline_shebang      = "/bin/sh -e"
    only                = ["qemu.jammy", "vbox.*"]
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }
  
  // post-processor "vagrant-cloud" {
  //   access_token = "${var.TOKEN_VAGRANT_CLOUD}"
  //   box_tag      = "markchristopherwest/${var.os_release}"
  //   version      = "${var.product_version}"
  //   version_description = "https://github.com/markchristopherwest/packer-cloud-init"
  //   only = ["qemu.jammy"]
  // }

  post-processor "vagrant" {
    compression_level    = 6
    keep_input_artifact  = true
    only                = ["qemu.jammy", "vbox.*"]
    output               = "/var/tmp/${var.vm_name}-${var.os_vendor}-${var.os_version}.box"
    vagrantfile_template = "${path.root}/${var.vagrantfile_template}"
  }

  post-processor "compress" {
    compression_level   = 6
    format              = ".gz"
    keep_input_artifact = true
    only                = ["qemu.jammy"]
    output              = "/var/tmp/${var.vm_name}-${var.os_vendor}-${var.os_version}.raw.gz"
  }
}