# hashicorp_demo

#build admin_box (optional)
Deploy EC2 instance via AWS console
use ./admin_box/user_data contents as EC2 user data

#packer create jenkins ami
cd /home/ec2-user/hashicorp_demo/jenkins/packer/
packer validate jenkins.json
packer build jenkins.json

#terraform deploy jenkins ec2
cd /home/ec2-user/hashicorp_demo/jenkins/terraform/
terraform init
terraform plan
terraform apply -auto-approve

#terraform generate vault certs
cd /home/ec2-user/hashicorp_demo/vault/terraform/private-tls-cert/
terraform init
terraform plan
terraform apply -auto-approve

#packer create vault ami
cd /home/ec2-user/hashicorp_demo/vault/packer/
packer validate vault-consul.json
packer build vault-consul.json

#terraform deploy vault ec2
cd /home/ec2-user/hashicorp_demo/vault/terraform/vault-consul/
terraform init
terraform plan
terraform apply -auto-approve

#terraform deploy demo_service
cd /home/ec2-user/hashicorp_demo/demo_service/
terraform init
terraform plan
terraform apply -auto-approve

