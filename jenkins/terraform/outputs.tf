output "jenkins_master_public_ip" {
  value = "${aws_instance.jenkins_master.public_ip}"
}
