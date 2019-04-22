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
  user_data = "${data.template_file.user_data_jenkins.rendered}"
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
