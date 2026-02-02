resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tmpl",
    {
      prd-pve-k3s-m01  = proxmox_vm_qemu.prd-pve-k3s-m01.default_ipv4_address
    }
  )
  filename = "${path.module}/../ansible/inventory/inventory.ini"

  lifecycle {
    postcondition {
      condition     = self.content != ""
      error_message = "L'inventaire Ansible est vide, vérifiez l'état des VMs Proxmox."
    }
  }
}