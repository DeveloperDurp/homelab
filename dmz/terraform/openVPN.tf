resource "proxmox_vm_qemu" "openVPN" {
  count       = local.openVPN.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.openVPN.ip[count.index]}"
  name        = local.openVPN.name[count.index]
  target_node = local.openVPN.node[count.index]
  clone       = local.template
  tags        = local.openVPN.tags
  qemu_os     = "l26"
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  cores       = local.openVPN.cores
  sockets     = 1
  cpu_type    = "host"
  memory      = local.openVPN.memory
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
          size    = local.openVPN.drive
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
  ipconfig0    = "ip=192.168.${local.vlan}.${local.openVPN.ip[count.index]}/24,gw=192.168.${local.vlan}.1"
  searchdomain = "durp.loc"
  nameserver   = local.dnsserver
}
