terraform {
  required_version = "~> 1.1.3"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.1"
    }
  }
}

provider "yandex" {
  service_account_key_file = file("token.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "yandex_compute_instance" "lipatnikov6" {
  name        = "${var.host_name}"
  zone        = "ru-central1-a"
  platform_id = "standard-v1"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.base_image.id
      type     = "network-nvme"
      size     = "30"
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = <<EOF
    "ubuntu:${var.pvt_key}" 
    "ubuntu:${var.rebrain_key}"
    EOF
  }
  labels = {
    user_email = "${var.labels_email}"
    task_name  = "${var.labels_devops}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.private_key}")
      host        = yandex_compute_instance.lipatnikov6.network_interface.0.nat_ip_address
    }
    inline = ["sudo passwd -d ubuntu",
      "yes ${element(random_string.password.*.result, 2)} | sudo passwd ubuntu",
      "sudo sed -i 's/#PermitRootLogin No/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sudo sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config",
      "sudo /etc/init.d/ssh restart"
    ]
  }
}

output "password" {
  value = random_string.password.*.result

}
resource "random_string" "password" {
  length = 8
}

data "yandex_vpc_subnet" "default" {
  name = "default-ru-central1-a"
}

data "yandex_compute_image" "base_image" {
  family = var.yc_image_family
}

locals {
  external_ips = ["${yandex_compute_instance.lipatnikov6.network_interface.0.nat_ip_address}"]
  internal_ips = ["${yandex_compute_instance.lipatnikov6.network_interface.0.ip_address}"]
  subnet_ids   = ["${data.yandex_vpc_subnet.default.id}"]

}

data "aws_route53_zone" "default" {
  name = "${var.aws_zone}"

}

resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "${var.host_name}"
  type    = "A"
  ttl     = "300"
  records = local.external_ips
}
