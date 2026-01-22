terraform{
    required_providers {
        proxmox = {
            version = "3.0.2-rc06"
            source = "Telmate/proxmox"
        }
    }
}
provider "proxmox" {
    pm_api_url = var.endpoint_proxmox

    pm_api_token_id= var.pm_api_token_id
    pm_api_token_secret = var.pm_api_token_secret

    pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "vm_ubuntu" {
    # Nom de la VM
    name = "01-SRV-UBU-24.04.5"
    vmid = 200
    target_node = "node1"
    
    # Nom du template exact du template Proxmox
    clone = "ubuntu-2404-cloud-template"

    # Type de clone (full#linked)
    full_clone= true

    # Configuration système (DOIT être cohérent avec template)
    agent = 1
    os_type = "cloud-init"

    # Ressources (Possibilité de surcharger les valeurs du template ici)
    cpu {
        type = "host"
        cores = 2
        sockets = 1
    }
    memory = 2048

    # Réseau
    network {
        model = "virtio"
        bridge = "vmbr0"
        id = 0
    }
    skip_ipv6 = true
    # Disque
    # Spécifier taille + stockage pour que Terraform sache où mettre le clone
    disk {
        slot = "scsi0"
        size = "20"
        type = "disk"
        storage = "local-zfs"
    }

    vga {
        type = "std"
    }
    # Ordre du boot
    boot = "order=scsi0;net0"

    # cloud-init
    ipconfig0 = "ip=dhcp"

    # Configuration SSH
    sshkeys = var.ssh_rsa_key
}