# do-k8s-cluster

A pre-configured Kubernetes cluster in Digital Ocean

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |
| digitalocean | >= 2.5.1 |

## Providers

| Name | Version |
|------|---------|
| digitalocean | >= 2.5.1 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [digitalocean_kubernetes_cluster](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster) |
| [digitalocean_kubernetes_versions](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/data-sources/kubernetes_versions) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Kubernetes cluster name | `string` | `"k8s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster | The generated Kubernetes cluster |
