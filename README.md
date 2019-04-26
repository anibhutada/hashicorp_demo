# hashicorp_demo

The purpose of this demo is to highlight a use case for Hashicorp Products.  The products chosen to demo are Vault, Terraform, Packer and Consul. 

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

#setup vault aws secrets backend (policies found at /hashicorp_demo/vault/policies)
vault secrets enable aws
vault write aws/config/root access_key={access-key} secret_key={secret-key} region=us-east-1 policy_document=@policyroot.json
vault write aws/roles/jenkins credential_type=federation_token policy_document=@policyrole.json

#setup vault userpass auth (policies found at /hashicorp_demo/vault/policies)
vault auth enable userpass
vault policy write jenkins jenkins.hcl
vault write auth/userpass/users/hashdemo password=hashdemo policies=jenkins

#gain vault credentials for jenkins pipeline
curl --request POST --data '{"password": "hashdemo"}' https://{vault-private-ip}:8200/v1/auth/userpass/login/hashdemo
curl -k --header "X-Vault-Token:s.eP93vbrSTUpoX3dMAnkhi8MZ"https://{vault-private-ip}:8200/v1/aws/creds/jenkins

#Jenkins/Terraform deploy demo_service with Vault token
Login to Jenkins server
Navigate to Manage Jenkins -> Manage Plugins and install Terraform Plugin
Navigate to Manage Jenkins -> Global Tool Configuration -> Terraform and create an installation named Terraform
Create a pipeline build that uses the git repo as SCM and /demo_service/jenkins-pipeline-demo-service-deploy as the pipeline file
Add three build paramets of password type (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_SESSION_TOKEN)
Save and Build with Parameters
Provide your Vault token generated in the previous step
