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

data "digitalocean_kubernetes_cluster" "this" {
  name = var.cluster_name
  depends_on = [
    module.do_k8s_cluster.cluster
  ]
}

module "do_k8s_cluster" {
  source       = "./modules/do-k8s-cluster"
  cluster_name = var.cluster_name
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

module "k8s_monitoring" {
  source    = "./modules/k8s-monitoring"
  namespace = "monitoring"
}
