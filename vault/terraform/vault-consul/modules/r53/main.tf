resource "aws_route53_record" "jenkins" {
  zone_id = "${var.hosted_zone}"
  name = "hashicorp_demo_vault.bap.com"
  type = "A"
  ttl = "300"
  records = ["$var.vault_public_ip}"]
}
