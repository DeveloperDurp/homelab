terraform {
  backend "http" {}
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc9"
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
  sshkeys   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEphzWgwUZnvL6E5luKLt3WO0HK7Kh63arSMoNl5gmjzXyhG1DDW0OKfoIl0T+JZw/ZjQ7iii6tmSLFRk6nuYCldqe5GVcFxvTzX4/xGEioAyG0IiUGKy6s+9xzO8QXF0EtSNPH0nfHNKcCjgwWAzM+Lt6gW0Vqs+aU5ICuDiEchmvYPz+rBaVldJVTG7m3ogKJ2aIF7HU/pCPp5l0E9gMOw7s0ABijuc3KXLEWCYgL39jIST6pFH9ceRLmu8Xy5zXHAkkEEauY/e6ld0hlzLadiUD7zYJMdDcm0oRvenYcUlaUl9gS0569IpfsJsjCejuqOxCKzTHPJDOT0f9TbIqPXkGq3s9oEJGpQW+Z8g41BqRpjBCdBk+yv39bzKxlwlumDwqgx1WP8xxKavAWYNqNRG7sBhoWwtxYEOhKXoLNjBaeDRnO5OY5AQJvONWpuByyz0R/gTh4bOFVD+Y8WWlKbT4zfhnN70XvapRsbZiaGhJBPwByAMGg6XxSbC6xtbyligVGCEjCXbTLkeKq1w0DuItY+FBGO3J2k90OiciTVSeyiVz9J/Y03UB0gHdsMCoVNrj+9QWfrTLDhM7D5YrXUt5nj2LQTcbtf49zoQXWxUhozlg42E/FJU/Yla7y55qWizAEVyP2/Ks/PHrF679k59HNd2IJ/aicA9QnmWtLQ== ansible"
  template  = "Debian12-Template"
  format    = "raw"
  dnsserver = "192.168.10.1"
  vlan      = 10
  k3smaster = {
    tags    = "k3s_dev"
    count   = 3
    name    = ["master01-dev", "master02-dev", "master03-dev"]
    cores   = 2
    memory  = "4096"
    drive   = 20
    storage = "cache-domains"
    node    = ["mothership", "overlord", "vanguard"]
    ip      = ["11", "12", "13"]
  }
  k3sserver = {
    tags    = "k3s_dev"
    count   = 3
    name    = ["node01-dev", "node02-dev", "node03-dev"]
    cores   = 4
    memory  = "8192"
    drive   = 120
    storage = "cache-domains"
    node    = ["mothership", "overlord", "vanguard"]
    ip      = ["21", "22", "23"]
  }
}
