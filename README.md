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

