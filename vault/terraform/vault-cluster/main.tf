provider "aws" {
    region = "${var.region}"
}

terraform {
    backend "s3" {
      region = "us-east-1"
      bucket = "hashicorp-demo-state"
      key = "terraform/jenkins/terraform.tfstate"
    }
    required_version = ">= 0.11.0"
}

data "terraform_remote_state""aws_global" {
    backend = "s3"
    config {
            region = "us-east-1"
            bucket = "hashicorp-demo-state"
            key = "terraform/jenkins/terraform.tfstate"
    }
}

data "aws_kms_alias" "vault-example" {
  name = "alias/${var.auto_unseal_kms_key_alias}"
}

data "aws_ami" "vault-server" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["vault-consul-hashicorop-demo"]
  }
}
module "vault_cluster" {
  source = "modules/vault-cluster"
  cluster_name  = "${var.vault_cluster_name}"
  cluster_size  = "${var.vault_cluster_size}"
  instance_type = "${var.vault_instance_type}"

  ami_id    = "${data.aws_ami.vault-server.id}"
  user_data = "${data.template_file.user_data_vault_cluster.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  enable_auto_unseal = true

  auto_unseal_kms_key_arn = "${data.aws_kms_alias.vault-example.target_key_arn}"

  allowed_ssh_cidr_blocks              = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks          = ["0.0.0.0/0"]
  allowed_inbound_security_group_ids   = []
  allowed_inbound_security_group_count = 0
  ssh_key_name                         = "${var.ssh_key_name}"
}

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.4.0"

  iam_role_id = "${module.vault_cluster.iam_role_id}"
}

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data-vault.sh")}"

  vars {
    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_name}"

    kms_key_id = "${data.aws_kms_alias.vault-example.target_key_id}"
    aws_region = "${data.aws_region.current.name}"
  }
}

module "security_group_rules" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.4.0"

  security_group_id = "${module.vault_cluster.security_group_id}"

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
}

module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.4.0"

  cluster_name  = "${var.consul_cluster_name}"
  cluster_size  = "${var.consul_cluster_size}"
  instance_type = "${var.consul_instance_type}"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = "${var.consul_cluster_tag_key}"
  cluster_tag_value = "${var.consul_cluster_name}"

  ami_id    = "${data.aws_ami.vault-server.id}"
  user_data = "${data.template_file.user_data_consul.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

data "template_file" "user_data_consul" {
  template = "${file("${path.module}/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${var.consul_cluster_name}"
  }
}

data "aws_vpc" "default" {
  default = "${var.vpc_id == "" ? true : false}"
  id      = "${var.vpc_id}"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_region" "current" {}
