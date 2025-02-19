resource "proxmox_vm_qemu" "pihole" {
  count       = local.pihole.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.pihole.ip[count.index]}"
  name        = local.pihole.name[count.index]
  target_node = local.pihole.node[count.index]
  clone       = local.template
  tags        = local.pihole.tags
  qemu_os     = "l26"
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  cores       = local.pihole.cores
  sockets     = 1
  cpu_type    = "host"
  memory      = local.pihole.memory
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
          size    = local.pihole.drive
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
  ipconfig0    = "ip=192.168.${local.vlan}.${local.pihole.ip[count.index]}/24,gw=192.168.${local.vlan}.1"
  searchdomain = "durp.loc"
  nameserver   = local.dnsserver
}
