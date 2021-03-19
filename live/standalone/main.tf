terraform {
  required_version = ">= 0.14"

  required_providers {

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.5.1"
    }

  }
}

variable "do_token" {
  type        = string
  description = "Digital Ocean access token"
  sensitive   = true
}

variable "ssh_key_id" {
  type        = string
  description = "Digital Ocean SSH key ID"
}

variable "ssh_key_path" {
  type        = string
  description = "Local path to SSH private key"
}

variable "ssh_user" {
  type        = string
  description = "Digital Ocean SSH user"
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "monitor" {
  image    = "ubuntu-20-04-x64"
  name     = "monitor"
  region   = "sfo3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_id]

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "adduser --disabled-password --gecos '' ${var.ssh_user}",
      "usermod -aG admin ${var.ssh_user}",
      "mkdir -p /home/${var.ssh_user}/.ssh",
      "chmod 0700 /home/${var.ssh_user}/.ssh",
      "cp /root/.ssh/authorized_keys /home/${var.ssh_user}/.ssh",
      "chmod 0600 /home/${var.ssh_user}/.ssh/authorized_keys",
      "chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}",
      "sed -i -e '/Defaults\\s\\+env_reset/a Defaults\\texempt_group=admin/' /etc/sudoers",
      "sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers",
      "visudo -cf /etc/sudoers",
      "sed -i -e 's/#PubkeyAuthentication/PubkeyAuthentication/g' /etc/ssh/sshd_config",
      "sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config",
      "/usr/sbin/sshd -t && systemctl reload sshd",
      "rm -rf /root/.ssh"
    ]
    connection {
      host        = self.ipv4_address
      agent       = false
      type        = "ssh"
      private_key = file(var.ssh_key_path)
      user        = "root"
      timeout     = "5m"
    }

  }
}
