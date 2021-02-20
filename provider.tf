terraform {

  required_version = ">= 0.14"
  
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.5.1"
    }
  }

}

variable "do_token" {
  type = string
}

provider "digitalocean" {
  token = var.do_token
}
