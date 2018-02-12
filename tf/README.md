# computeclassic-demo - Terraform files
Demo of Oracle Compute Classic with Terraform

## RUN
terraform init
terraform plan -var-file=~/secrets/file.tfvars
terraform apply -var-file=~/secrets/file.tfvars

file.tfvars contains:
user = "user@server.com"
password = "xxxxxxxx"
identity_domain = "myidentitydomain"
compute_endpoint = "https://compute.uscom-central-1.oraclecloud.com/"
