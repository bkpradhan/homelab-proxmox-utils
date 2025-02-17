#! /bin/bash
#Enhanced from https://github.com/UntouchedWagons/Ubuntu-CloudInit-Docs/blob/main/README.md -- see this for more instructions
VMUSER=$1
if [ "x$VMUSER" == "x" ]; then
        echo "VM user is not provided, pls provide as arg 1 i.e $0 testuser"
        exit 1;
fi

# prior to running this set in your shell i.e export CLEARTEXT_PASSWORD=yourvmpassword
if [ "x$CLEARTEXT_PASSWORD" == "x" ]; then
        echo "VM user $VMUSER password is not set, pls set CLEARTEXT_PASSWORD as env var"
        exit 1;
fi
read -e -p "Would you like to proceed(Yy/Nn)?"  choice
[[ "$choice" != [Yy]* ]] && echo "Aboring.." && exit 1

echo "Starting creating VM template.."

VMID=11111
STORAGE=local-zfs
IMG_NAME=noble-server-cloudimg-amd64.img
DISK_SIZE=32G

set -x
if [ -f $IMG_NAME ]; then
    echo "Old $IMG_NAME found! Removing.." && rm -f $IMG_NAME
fi

wget -q https://cloud-images.ubuntu.com/noble/current/$IMG_NAME
qemu-img resize $IMG_NAME $DISK_SIZE
 qm destroy $VMID
 qm create $VMID --name "ubuntu-noble-template" --ostype l26 \
    --memory 1024 --balloon 0 \
    --agent 1 \
    --bios ovmf --machine q35 --efidisk0 $STORAGE:0,pre-enrolled-keys=0 \
    --cpu host --socket 1 --cores 1 \
    --vga serial0 --serial0 socket  \
    --net0 virtio,bridge=vmbr0
 qm importdisk $VMID $IMG_NAME $STORAGE
 qm set $VMID --scsihw virtio-scsi-pci --virtio0 $STORAGE:vm-$VMID-disk-1,discard=on
 qm set $VMID --boot order=virtio0
 qm set $VMID --scsi1 $STORAGE:cloudinit

cat << EOF |  tee /var/lib/vz/snippets/ubuntu.yaml
#cloud-config
runcmd:
    - apt-get update
    - apt-get install -y qemu-guest-agent
    - systemctl enable ssh
    - reboot
# Taken from https://forum.proxmox.com/threads/combining-custom-cloud-init-with-auto-generated.59008/page-3#post-428772
EOF

 qm set $VMID --cicustom "vendor=local:snippets/ubuntu.yaml"
 qm set $VMID --tags ubuntu-template,noble,cloudinit
 qm set $VMID --ciuser $VMUSER
 qm set $VMID --cipassword $(openssl passwd -6 $CLEARTEXT_PASSWORD)
 qm set $VMID --sshkeys ~/.ssh/authorized_keys
 qm set $VMID --ipconfig0 ip=dhcp
 qm template $VMID
