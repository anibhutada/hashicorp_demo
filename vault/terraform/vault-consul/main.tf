provider "aws" {
    region = "${var.region}"
}

terraform {
    backend "s3" {
      region = "us-east-1"
      bucket = "hashicorp-demo-state"
      key = "terraform/vault/terraform.tfstate"
    }
}

module "ec2" {
    source = "./modules/ec2"
    region = "${var.region}"
    vault_instance_type = "${var.vault_instance_type}"
    vault_public_ip = "${module.ec2.vault_public_ip}"
    key_name = "${var.key_name}"
    vault_sg_name = "${var.vault_sg_name}"
    }

module "r53" {
    source = "./modules/r53"
    hosted_zone = "${var.hosted_zone}"
    vault_public_ip = "${module.ec2.vault_public_ip}"
    }

 output "vault_public_ip" {
     value = "${module.ec2.vault_public_ip}"
    }
