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
data "aws_ami" "jenkins-master" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-master-hashiscorp-demo"]
  }
}

data "template_file" "user_data_jenkins" {
  template = "${file("source/email_jpwd.tpl")}"
}

resource "aws_instance" "jenkins_master" {
  ami                    = "${data.aws_ami.jenkins-master.id}"
  instance_type          = "${var.jenkins_master_instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.master_sg_name}"]
  user_data = "${data.template_file.user_data_jenkins.rendered}"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = false
  }

  tags {
    Name   = "jenkins_master"
    Project   = "hashicorp_demo"
  }
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${var.hosted_zone}"
  name = "hashicorp_demo_jenkins.bap.com"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.jenkins_master.public_ip}"]
}
