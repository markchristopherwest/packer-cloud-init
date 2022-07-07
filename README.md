# packer-cloud-init

## Getting Started

Get started with Packer builder QEMU today!

```bash
# All Chips
packer init
PACKER_LOG=1 packer build config.pkr.hcl
```

```bash
# https://gitlab.com/libvirt/libvirt/-/issues/75
git clone https://github.com/lima-vm/vde_vmnet.git
cd vde_vmnet
sudo git config --global --add safe.directory /home/dude/github/vde_vmnet
sudo make PREFIX=/opt/vde install
qemu-system-$(uname -m) \
  -device virtio-net-pci,netdev=net0 -netdev vde,id=net0,sock=/var/run/vde.ctl \
  -m 4096 -accel hvf -cdrom /var/tmp/b9441068de828d36573e1274dfe77f69aebda15a.iso
```

```bash
sudo apt-get install -y virtinst virt-manager
virt-install --import --name foo \
--memory 4096 --vcpus 2 --cpu host \
--disk /var/tmp/ubuntu-22.04/vagrant.qcow2,format=qcow2,bus=virtio \
--network bridge=virbr0,model=virtio \
--os-type=linux \
--os-variant=ubuntu22.04 \
--graphics spice \
--noautoconsole
virsh list
virsh net-dhcp-leases default

vagrant up
# vagrant global-status
# vagrant destroy -f
```

```bash
# Amazon
qemu-img convert /var/tmp/vagrant-ubuntu-22.04.qcow2 /var/tmp/vagrant-ubuntu-22.04.raw
aws s3api create-bucket \
    --bucket yolo-jammy-jellyfish \
    --region us-east-1

touch trust-policy.json
aws iam create-role --role-name vmimport --assume-role-policy-document file://trust-policy.json
touch role-policy.json
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://role-policy.json


 {
     "Description": "Example image originally in QCOW2 format",
     "Format": "raw",
     "Url": "https://s3-us-west-2.amazonaws.com/raw-images/example.raw"
 }
aws ec2 import-snapshot --description "example image" --disk-container file://container.json

```