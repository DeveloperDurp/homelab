resource "proxmox_vm_qemu" "haproxy" {
  count       = local.haproxy.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.haproxy.ip[count.index]}"
  name        = local.haproxy.name[count.index]
  target_node = local.haproxy.node[count.index]
  clone       = local.template
  tags        = local.haproxy.tags
  qemu_os     = "l26"
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  cores       = local.haproxy.cores
  sockets     = 1
  cpu_type    = "host"
  memory      = local.haproxy.memory
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
          storage = local.haproxy.storage
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = local.haproxy.drive
          format  = local.format
          storage = local.haproxy.storage
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
  ipconfig0    = "ip=192.168.${local.vlan}.${local.haproxy.ip[count.index]}/24,gw=192.168.${local.vlan}.1"
  searchdomain = "durp.loc"
  nameserver   = local.dnsserver
}

resource "proxmox_vm_qemu" "postgres" {
  count       = local.postgres.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.postgres.ip[count.index]}"
  name        = local.postgres.name[count.index]
  target_node = local.postgres.node[count.index]
  clone       = local.template
  tags        = local.postgres.tags
  qemu_os     = "l26"
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  cores       = local.postgres.cores
  sockets     = 1
  cpu_type    = "host"
  memory      = local.postgres.memory
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
          size    = local.postgres.drive
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
  ipconfig0    = "ip=192.168.${local.vlan}.${local.postgres.ip[count.index]}/24,gw=192.168.${local.vlan}.1"
  searchdomain = "durp.loc"
  nameserver   = local.dnsserver
}
