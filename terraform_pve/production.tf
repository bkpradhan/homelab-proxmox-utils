resource "proxmox_vm_qemu" "production" {
    vmid = 502  
    name = "ubuntu-um-terraform"
    target_node = "pve" # your proxmox node

    clone = "ubuntu-noble-template" # template name already existing in pve
    full_clone = true
    # bios = "ovmf"
    # agent = 1
    # scsihw = "virtio-scsi-single"
    # os_type = "ubuntu"
    memory = 2048
    # cpu_type = "x86-64-v2-AES"
    cores = 2
    # sockets = 1
  
    # disks {
    #     scsi {
    #         scsi0 {
    #             disk {
    #             storage = "local-zfs"
    #             size = "32G"
    #             format = "qcow2"
    #             }
    #         }
    #     }
    # }

  ### or for a Clone VM operation
  # clone = "template to clone"

  ### or for a PXE boot VM operation
  # pxe = true
  # boot = "scsi0;net0"
  # agent = 0
}