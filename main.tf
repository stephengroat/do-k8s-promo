
data "digitalocean_kubernetes_versions" "main" {
  version_prefix = "1.20."
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name         = "k8s"
  region       = "sfo3"
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.main.latest_version

  node_pool {
    name       = "default"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}
