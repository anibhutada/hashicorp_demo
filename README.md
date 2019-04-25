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
chmod 777 modules/run-vault/run-vault
chmod 777 modules/install-vault/install-vault
chmod 777 modules/update-certificate-store/update-certificate-store
packer validate vault-consul.json
packer build vault-consul.json

#terraform deploy vault cluster
cd /home/ec2-user/hashicorp_demo/vault/terraform/vault-cluster/
terraform init
terraform plan
terraform apply -auto-approve
ssh -i {file}.pem ec2-user@{vault-server-ip}
vault operator init
export VAULT_TOKEN={provided client token}

#validate vault status
from vault_box; vault status
from admin_box ; curl -k https://{vault-private-ip}:8200/v1/sys/health

#setup vault aws secrets backend (policies found at /hashicorp_demo/vault/policies
vault secrets enable aws
vault write aws/config/root access_key={access-key} secret_key={secret-key} region=us-east-1 policy_document=@policyroot.json
vault write aws/roles/jenkins credential_type=federation_token policy_document=@policyrole.json
vault read aws/creds/jenkins

#setup vault userpass auth
vault auth enable userpass
vault write auth/userpass/users/hashdemo password=hashdemo

#terraform deploy demo_service
cd /home/ec2-user/hashicorp_demo/demo_service/
terraform init
terraform plan
terraform apply -auto-approve
