terraform {
  required_version = ">= 0.14"

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.2"
    }

  }
}

variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Name of a namespace which will be created for deploying the resources"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
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
