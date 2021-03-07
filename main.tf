terraform {
  required_version = ">= 0.14"

  required_providers {

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.5.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0.2"
    }

  }
}

variable "do_token" {
  type        = string
  description = "Digital Ocean access token"
  sensitive   = true
}

variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
  default     = "k8s"
}

provider "digitalocean" {
  token = var.do_token
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

data "digitalocean_kubernetes_cluster" "this" {
  name = var.cluster_name
  depends_on = [
    digitalocean_kubernetes_cluster.this
  ]
}

provider "kubernetes" {

  host = data.digitalocean_kubernetes_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = [
      "kubernetes",
      "cluster",
      "kubeconfig",
      "exec-credential",
      "--version=v1beta1",
      data.digitalocean_kubernetes_cluster.this.id
    ]
  }

}

provider "helm" {
  kubernetes {

    host = data.digitalocean_kubernetes_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
    )

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "doctl"
      args = [
        "kubernetes",
        "cluster",
        "kubeconfig",
        "exec-credential",
        "--version=v1beta1",
        data.digitalocean_kubernetes_cluster.this.id
      ]
    }

  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube-prometheus" {
  name       = "kube-prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  recreate_pods   = true
  reuse_values    = true
  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 300
  max_history     = 2

}
