# computeclassic-demo
Deployment of a 3 tier application on Oracle Compute Classic. Oracle Compute
Classic runs on Oracle Cloud Infrastructure Classic and Oracle Cloud at Customer.
The deployment topology is the following:
![Topology](/ComputeClassicDemo-topology.png)

The application source code is located at https://github.com/gregvers/hitcount

## Deploy using Orchestration v2  
### From the CLI:  
Download and install the CLI following instructions at https://docs.oracle.com/en/cloud/iaas/compute-iaas-cloud/stopc/preparing-use-cli.html  
Run the following commands  
$ cd orchestration-v2  
$ opc compute orchestration-v2 add computeclassic-demo.json  

### From the Compute-Classic console:  
upload orchestration and select computeclassic-demo.json in folder orchestration-v2  

## Deploy using Terraform  
Download and install Terraform from https://www.terraform.io/  
Run the following commands  
$ cd terraform
$ terraform init  
$ terraform plan -var-file=/location/file.tfvars  
$ terraform apply -var-file=/location/file.tfvars  

file.tfvars contains:  
user = "user@server.com"  
password = "xxxxxxxx"  
identity_domain = "myidentitydomain"  
compute_endpoint = "https://compute.uscom-central-1.oraclecloud.com/"  
