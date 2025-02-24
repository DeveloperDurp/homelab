resource "proxmox_vm_qemu" "k3smaster" {
  count       = local.k3smaster.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.k3smaster.ip[count.index]}"
  name        = local.k3smaster.name[count.index]
  target_node = local.k3smaster.node[count.index]
  clone       = local.template
  tags        = local.k3smaster.tags
  qemu_os     = "l26"
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  cores       = local.k3smaster.cores
  sockets     = 1
  cpu_type    = "host"
  memory      = local.k3smaster.memory
  scsihw      = "virtio-scsi-pci"
  #bootdisk    = "scsi0"
  boot    = "order=virtio0"
  onboot  = true
  sshkeys = local.sshkeys
  vga {
    type = "serial0"
  }
  serial {
    id   = 0
    type = "socket"
  }
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = local.storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = local.k3smaster.drive
          format  = local.format
          storage = local.storage
        }
      }
    }
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = local.vlan
  }
  #Cloud Init Settings
  ipconfig0    = "ip=192.168.${local.vlan}.${local.k3smaster.ip[count.index]}/24,gw=192.168.${local.vlan}.1"
  searchdomain = "durp.loc"
  nameserver   = local.dnsserver
}

resource "proxmox_vm_qemu" "k3sserver" {
  count       = local.k3sserver.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.k3sserver.ip[count.index]}"
  name        = local.k3sserver.name[count.index]
  target_node = local.k3sserver.node[count.index]
  clone       = local.template
  tags        = local.k3sserver.tags
  qemu_os     = "l26"
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  cores       = local.k3sserver.cores
  sockets     = 1
  cpu_type    = "host"
  memory      = local.k3sserver.memory
  scsihw      = "virtio-scsi-pci"
  #bootdisk    = "scsi0"
  boot    = "order=virtio0"
  onboot  = true
  sshkeys = local.sshkeys
  vga {
    type = "serial0"
  }
  serial {
    id   = 0
    type = "socket"
  }
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = local.storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = local.k3sserver.drive
          format  = local.format
          storage = local.storage
        }
      }
    }
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = local.vlan
  }
  #Cloud Init Settings
  ipconfig0    = "ip=192.168.${local.vlan}.${local.k3sserver.ip[count.index]}/24,gw=192.168.${local.vlan}.1"
  searchdomain = "durp.loc"
  nameserver   = local.dnsserver
}
