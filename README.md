# Assignment 3

## Name = Rishab Rajesh Agarwal

## NUID = 002766211

## Email = agarwal.risha@northeastern.edu

## The assignment was to build Infrastructure for the AWS which includes VPC, Subnets - Public and Private, Route tables, Internet gateway,etc

## Everthing should be such that it should be configured dynamically and minimal manual intervention is allowed and is to be kept in mind.In order to achieve the above used variables supported by the Terraform.

## The code should be such that it should work in an region, and also multiple vpcs should be able to create without any problems in same region and in the same AWS account. Also, for different regions too the same workaround.


## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - Add the dev.tfvars or demo.tfvars file (with all the variables defined) in the root directory
    - terraform init
    - terraform plan -var-file="file_name.tfvars"
    - terraform apply -var-file="file_name.tfvars"
    - terraform destroy -var-file="file_name.tfvars"


## Steps followed for the assignment were as follows:
1. Downloaded aws cli for dev and prod profiles to configure aws using both of the credentials of the dev and prod. 
2. Installed terraform in my machine to write IaaC to build the infrastructure as mentioned in the assignment.  
3. Read the terraform documentation in order to write the code to create infrastructure
4. Worked in the dev profile in order to develop the code
5. Ran the terraform commands to run the code
6. Also created .tf file for variable declaration and created .tfvars file to define those declared variables in the .tf variable files
7. Added necessary terraform files like state and lock files to be ignored in the .gitignore file.



# Assignment 4

## The assignment was to build Infrastructure for the AWS which includes VPC, Subnets - Public and Private, Route tables, Internet gateway,etc 

## We need to create Ec2 instance and attacn an ami, ebs and other specs as per the requirement.


## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - Add the dev.tfvars or demo.tfvars file (with all the variables defined) in the root directory
    - terraform init
    - terraform plan -var-file="file_name.tfvars"
    - terraform apply -var-file="file_name.tfvars"
    - terraform destroy -var-file="file_name.tfvars"


## Steps followed for the assignment were as follows:
1. Read the terraform documentation in order to write the code to create infrastructure
2. Worked in the dev profile in order to develop the code
3. Ran the terraform commands to run the code
6. Created ec2 and security groups using terraform
7. Used demo as a profile to launch the ami


# Assignment 6

## The assignment was to configure Amazon Route 53 For DNS Service.

## Updated Route53 record in the Terraform template

## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - Add the dev.tfvars or demo.tfvars file (with all the variables defined) in the root directory
    - terraform init
    - terraform plan -var-file="file_name.tfvars"
    - terraform apply -var-file="file_name.tfvars"
    - terraform destroy -var-file="file_name.tfvars"


## Steps followed for the assignment were as follows:
1. Wrote the code to add record of type "A" for route53
2. Worked in the dev profile in order to develop the code
3. Ran the terraform commands to run the code
6. Created the infrastructure and tested the application using the domain name


# Assignment 7

## The assignment was to download, install and configure cloudwatch agent.

## Need to add policy for Cloudwatch services and attach it to an Ec2 instance role so that Ec2 can access it.

## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - Add the dev.tfvars or demo.tfvars file (with all the variables defined) in the root directory
    - terraform init
    - terraform plan -var-file="file_name.tfvars"
    - terraform apply -var-file="file_name.tfvars"
    - terraform destroy -var-file="file_name.tfvars"


## Steps followed for the assignment were as follows:
1. Wrote the code to add iam policy for Cloudwatch service
2. Attached the policy to the Ec2 role
3. Added a command to run the cloudwatch agent in user data script
4. Worked in the dev profile in order to develop the code
5. Ran the terraform commands to run the code
6. Created the infrastructure and tested the application using the domain name

# Assignment 8

## The assignment was to add Ec2 launch template, load balancer & auto scaling group.

## Need to configure the entire infrastructure changes for load balancer, launch template and auto scaling group and its policies.

## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - Add the dev.tfvars or demo.tfvars file (with all the variables defined) in the root directory
    - terraform init
    - terraform plan -var-file="file_name.tfvars"
    - terraform apply -var-file="file_name.tfvars"
    - terraform destroy -var-file="file_name.tfvars"


## Steps followed for the assignment were as follows:
1. Wrote the code to add launch template for EC2 instances
2. Created a shell script in order to run the user data script and passed it to launch template
3. Added and updated security groups for Load balancer and Ec2 instances
4. Removed the resource of Ec2 instance
5. Configured Auto Scaling group and its policies.
6. Added cloudwatch alarms which will trigger the scale up and down policies as per the alarm
7. Made updates in the Route53 by adding alias for Load balancer DNS name
8. Worked in the dev profile in order to develop the code
9. Ran the terraform commands to run the code
10. Created the infrastructure and tested the application using the domain name


# Assignment 9

## The assignment was to add ssl certificates for dev and prod environments, encrypt the RDS instance and EBS volumes.

## Need to configure the entire infrastructure changes for ssl certificates & KMS keys

## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - Add the dev.tfvars or demo.tfvars file (with all the variables defined) in the root directory
    - terraform init
    - terraform plan -var-file="file_name.tfvars"
    - terraform apply -var-file="file_name.tfvars"
    - terraform destroy -var-file="file_name.tfvars"

3. The command to import the certificate is as follows :
    - aws acm import-certificate --certificate fileb://prod_rishabagarwal_me.crt --certificate-chain fileb://prod_rishabagarwal_me.ca-bundle --private-key fileb://private.key


## Steps followed for the assignment were as follows:
1. Wrote the code to add KMS keys for both the RDS and EBS volumes
2. Created policies for RDS and Ebs volumes and attached it the respective keys
3. Made changes to load balancer listener by changing the port from 80 t0 443 and the protocol from HTTP to HTTPS
4. Added configuration for SSL certification by attaching it to the load balancer listener
5. Worked in the dev profile in order to develop the code
6. Ran the terraform commands to run the code
7. Created the infrastructure and tested the application using the domain name