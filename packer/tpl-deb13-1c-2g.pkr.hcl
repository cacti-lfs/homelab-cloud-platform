packer {
  required_plugins {
    proxmox = {
      version = "=1.1.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "tpl-deb13-1c-2g" {
    #http_bind_address = "0.0.0.0" # A personnaliser avec l'IP de son poste
    http_interface    = "enx00e04c78472e"
    http_port_min = 8539
    http_port_max = 8539
  # Connexion API
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  
  # Destination
  node                 = var.proxmox_node
  vm_id                = 9010
  vm_name              = var.vm_name
  template_description = "Template Debian Trixie créé par Packer le ${formatdate("YYYY-MM-DD", timestamp())}"

  # Configuration VM
  cores                = 2
  memory               = 2048
  scsi_controller      = "virtio-scsi-pci"
  
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size         = "10G"
    format            = "raw"
    storage_pool      = "local-zfs"
    type              = "scsi"
  }

  # ISO
  iso_storage_pool = "local"
  iso_file         = "local:iso/SRV_DEB_13.3.0.iso" # A personnaliser avec le nom de l'ISO sur Proxmox
  unmount_iso      = true

  # SSH & Preseed
  ssh_username     = "cloudadm"
  ssh_password     = var.ssh_password
  ssh_timeout      = "20m"
  http_directory   = "."
  
  # Même boot_command que pour VirtualBox
    boot_command = [
        "<esc><wait>",
        "install <wait>",
        " netcfg/choose_interface=auto <wait>",
        " <wait10s>",
        " auto=true priority=critical preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
        " locale=fr_FR <wait>",
        " console-setup/ask_detect=false <wait>",
        " keyboard-configuration/xkb-keymap=fr(latin9) <wait>",
        " fb=false <wait>",
        " vga=788 -- <wait>",
        "<enter><wait>"
    ]
}

build {
  sources = ["source.proxmox-iso.tpl-deb13-1c-2g"]

  provisioner "shell" {
    # On passe le mot de passe via l'entrée standard (-S) pour sudo
    execute_command = "echo '${var.ssh_password}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get install -y cloud-init qemu-guest-agent",
      "cloud-init clean",
      "truncate -s 0 /etc/machine-id",
      "systemctl enable qemu-guest-agent"
    ]
  }
}