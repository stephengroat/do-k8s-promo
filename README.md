# do-k8s-promo

## TODO:

- persistent storage
- set up Loki w/ Grafana
- multicluster and Prometheus federation
  - use simple Prometheus chart
- create github action for terraform-docs
- relabeling config for the target prometheuses

Example central Prometheus config:

```yaml
# basic config for the central prometheus hub
prometheus.yml:
    rule_files:
      - /etc/config/rules
      - /etc/config/alerts

    scrape_configs:
      - job_name: 'federate'
        scrape_interval: 15s

        honor_labels: true
        metrics_path: '/federate'

        params:
          'match[]':
            - '{job="prometheus"}'
            - '{__name__=~"job:.*"}'

        static_configs:
          - targets:
            - 'prometheus-server:80'
```

Next level:

- fault injection e.g. Kraken
- some useful applications? e.g. Huginn

## Pre-Requisites

1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

2. Install [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

3. Install [Helm](https://helm.sh/docs/intro/install/)

4. Install [doctl](https://www.digitalocean.com/docs/apis-clis/doctl/how-to/install/)

5. (Optionally) Install [s3cmd](https://github.com/s3tools/s3cmd/blob/master/INSTALL.md)

6. Add a valid Digital Ocean API token to a file with the `.tfvars` extension, e.g. `terraform.tfvars`:

```hcl
do_token = "hextokenfromdigitalocean"
```

## Deploy

```sh
terragrunt init
terragrunt plan
terragrunt apply
```

## Get kube config

This example saves the kube config to a file at the root of the project:

(Files named `*.kubeconfig.yml` are being ignored by `.gitignore`.)

```sh
export TF_VAR_cluster_name="k8s"
export KUBECONFIG_BAK="$KUBECONFIG"
export KUBECONFIG="$(pwd)/do-k8s.kubeconfig.yml"
doctl kubernetes cluster kubeconfig save "$TF_VAR_cluster_name"
```

## References

<https://www.digitalocean.com/docs/kubernetes/>

<https://www.padok.fr/en/blog/digitalocean-kubernetes>
