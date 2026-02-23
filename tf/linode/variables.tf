variable "toplevel_domain" {
  type        = string
  description = "The toplevel domain on which the rest of the subdomains will be placed"
  nullable = false
}

variable "ssh_key" {
  type = string
  description = "the ssh key to use for all VMs. Empty string disables ssh"
  nullable = false
}
