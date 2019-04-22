
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

module "ec2" {
    source = "./modules/ec2"
    region = "${var.region}"
    instance_type = "${var.vault_instance_type}"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${var.vault_sg_name}"]
    }
 
module "r53" {
    source = "./modules/r53"
    zone_id = "${var.hosted_zone}"
    records = ["${module.ec2.vault_public_ip}"]
    }

 ouput "vault_public_ip" {
     value = "${module.ec2.vault_public_ip}"
    }
