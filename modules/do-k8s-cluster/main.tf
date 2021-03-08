/**
 * # do-k8s-cluster
 *
 * A pre-configured Kubernetes cluster in Digital Ocean
 *
 */

terraform {
  required_version = ">= 0.14"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.5.1"
    }
  }
}


variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
  default     = "k8s"
}

data "digitalocean_kubernetes_versions" "main" {
  version_prefix = "1.20."
}

resource "digitalocean_kubernetes_cluster" "this" {

  name         = var.cluster_name
  region       = "sfo3"
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.main.latest_version

  node_pool {
    name       = "workers"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }

}
