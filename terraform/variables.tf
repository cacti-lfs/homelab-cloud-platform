variable "api_token" {
    type = string
    sensitive = true
    # Tu passeras la valeur via un fichier terraform.tfvars ou une variable d'environnement
    # Format attendu par bpg : "USER@REALM!TOKENID=UUID"
}

variable "endpoint_proxmox" {
    type = string
    sensitive = false
}

variable "user_ssh" {
    type = string
    sensitive = false
}