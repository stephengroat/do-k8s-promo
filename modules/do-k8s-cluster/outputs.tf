output "cluster" {
  value = digitalocean_kubernetes_cluster.this
  description = "The generated Kubernetes cluster"
}
