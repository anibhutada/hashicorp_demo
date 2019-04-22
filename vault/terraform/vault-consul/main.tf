
provider "aws" {
    region = "${var.region}"
}

terraform {
    backend "s3" {
      region = "us-east-1"
      bucket = "hashicorp-demo-state"
      key = "terraform/jenkins/terraform.tfstate"
    }
}

data "terraform_remote_state""aws_global" {
    backend = "s3"
    config {
            region = "us-east-1"
            bucket = "hashicorp-demo-state"
            key = "terraform/jenkins/terraform.tfstate"
    }
}
data "aws_ami" "vault-consul" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["vault-consul-hashicorop-demo"]
  }
}

resource "aws_instance" "vault" {
  ami                    = "${data.aws_ami.vault-consul.id}"
  instance_type          = "${var.vault_instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.vault_sg_name}"]
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  tags {
    Name   = "vault-consul"
    Project   = "hashicorp_demo"
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${var.hosted_zone}"
  name = "hashicorp_demo_vault.bap.com"
  type = "A"
  ttl = "300"
  records = ["${var.vault_public_ip}"]
}
