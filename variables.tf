variable "admin_username" {
  description = "Admin username for all Windows VMs"
  type        = string
}

variable "admin_password" {
  description = "Admin password for all Windows VMs"
  type        = string
  sensitive   = true
}
