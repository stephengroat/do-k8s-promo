output "droplet" {
  value = {
    "monitor" = {
      "id"                   = digitalocean_droplet.monitor.id
      "name"                 = digitalocean_droplet.monitor.name
      "urn"                  = digitalocean_droplet.monitor.urn
      "image"                = digitalocean_droplet.monitor.image
      "size"                 = digitalocean_droplet.monitor.size
      "disk"                 = digitalocean_droplet.monitor.disk
      "region"               = digitalocean_droplet.monitor.region
      "ipv4_address"         = digitalocean_droplet.monitor.ipv4_address
      "ipv4_address_private" = digitalocean_droplet.monitor.ipv4_address_private
    }
  }
}
