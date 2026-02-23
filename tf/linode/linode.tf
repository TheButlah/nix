terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "3.8.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.17.0"
    }
  }
}

# Configure the Linode Provider
provider "linode" {
  # token = "..." # instead we use LINODE_TOKEN env var
}

resource "linode_instance" "matrix" {
  label           = "matrix"
  image           = "linode/ubuntu24.04"
  region          = "us-east"
  type            = "g6-nanode-1"
  authorized_keys = var.ssh_key == "" ? []: [var.ssh_key]

  tags       = []
  swap_size  = 256
  private_ip = true
}

output "foo" {
  value = linode_instance.matrix.authorized_keys
}

data "linode_instance_networking" "matrix" {
  linode_id = linode_instance.matrix.id
}

data "cloudflare_zone" "toplevel_domain" {
  filter = {
    match = "all"
    name  = var.toplevel_domain
  }
}

resource "cloudflare_dns_record" "matrix_A" {
  zone_id = data.cloudflare_zone.toplevel_domain.zone_id
  name    = "matrix.${data.cloudflare_zone.toplevel_domain.name}"
  ttl     = 60
  type    = "A"
  comment = "matrix identity and homeserver"
  content = data.linode_instance_networking.matrix.ipv4[0].public[0].address
  proxied = false
}
