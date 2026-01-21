terraform {
  required_providers {
    proxmox = {
        source = "bpg/proxmox"
        version = "0.93.0"
    }
  }
}

provider "proxmox" {
    endpoint = var.endpoint_proxmox
    api_token = var.api_token
    insecure = true
    ssh {
        agent = true
        username = "root"
    }
}