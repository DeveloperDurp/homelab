terraform {
  backend "http" {}
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  pm_parallel     = 1
  pm_tls_insecure = true
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_debug        = false
}

locals {
  sshkeys    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEphzWgwUZnvL6E5luKLt3WO0HK7Kh63arSMoNl5gmjzXyhG1DDW0OKfoIl0T+JZw/ZjQ7iii6tmSLFRk6nuYCldqe5GVcFxvTzX4/xGEioAyG0IiUGKy6s+9xzO8QXF0EtSNPH0nfHNKcCjgwWAzM+Lt6gW0Vqs+aU5ICuDiEchmvYPz+rBaVldJVTG7m3ogKJ2aIF7HU/pCPp5l0E9gMOw7s0ABijuc3KXLEWCYgL39jIST6pFH9ceRLmu8Xy5zXHAkkEEauY/e6ld0hlzLadiUD7zYJMdDcm0oRvenYcUlaUl9gS0569IpfsJsjCejuqOxCKzTHPJDOT0f9TbIqPXkGq3s9oEJGpQW+Z8g41BqRpjBCdBk+yv39bzKxlwlumDwqgx1WP8xxKavAWYNqNRG7sBhoWwtxYEOhKXoLNjBaeDRnO5OY5AQJvONWpuByyz0R/gTh4bOFVD+Y8WWlKbT4zfhnN70XvapRsbZiaGhJBPwByAMGg6XxSbC6xtbyligVGCEjCXbTLkeKq1w0DuItY+FBGO3J2k90OiciTVSeyiVz9J/Y03UB0gHdsMCoVNrj+9QWfrTLDhM7D5YrXUt5nj2LQTcbtf49zoQXWxUhozlg42E/FJU/Yla7y55qWizAEVyP2/Ks/PHrF679k59HNd2IJ/aicA9QnmWtLQ== ansible"
  template   = "Debian12-Template"
  storage    = "cache-domains"
  emulatessd = true
  format     = "raw"
  dnsserver  = "192.168.12.1"
  tags       = "postgres"
  vlan       = 12
  haproxy = {
    count  = 3
    name   = ["haproxy-01", "haproxy-02", "haproxy-03"]
    cores  = 2
    memory = "1024"
    drive  = 20
    node   = ["mothership", "overlord", "vanguard"]
    ip     = ["31", "32", "33"]
  }
  postgres = {
    count  = 3
    name   = ["postgres-01", "postgres-02", "postgres-03"]
    cores  = 4
    memory = "4096"
    drive  = 40
    node   = ["mothership", "overlord", "vanguard"]
    ip     = ["34", "35", "36"]
  }
}

resource "proxmox_vm_qemu" "haproxy" {
  count       = local.haproxy.count
  ciuser      = "administrator"
  vmid        = "${local.vlan}${local.haproxy.ip[count.index]}"
  name        = local.haproxy.name[count.index]
  target_node = local.haproxy.node[count.index]
  clone       = local.template
  tags        = local.tags
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
          size    = local.haproxy.drive
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
  tags        = local.tags
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
