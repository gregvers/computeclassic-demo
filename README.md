# computeclassic-demo
Demo of Oracle Compute Classic

![Topology](/ComputeClassicDemo-topology.png)

## Deploy using Orchestration v2  
From the CLI:  
$ cd orchestration-v2  
$ opc compute orchestration-v2 add computeclassic-demo.json  
For more information on the CLI, refer to https://docs.oracle.com/en/cloud/iaas/compute-iaas-cloud/stopc/preparing-use-cli.html  

From the Compute-Classic console:  
upload orchestration and select computeclassic-demo.json in folder orchestration-v2  

## Deploy using Terraform  
$ terraform init  
$ terraform plan -var-file=/location/file.tfvars  
$ terraform apply -var-file=/location/file.tfvars  

file.tfvars contains:  
user = "user@server.com"  
password = "xxxxxxxx"  
identity_domain = "myidentitydomain"  
compute_endpoint = "https://compute.uscom-central-1.oraclecloud.com/"  
