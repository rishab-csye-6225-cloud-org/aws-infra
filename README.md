# Assignment 3

## Name = Rishab Rajesh Agarwal

## NUID = 002766211

## Email = agarwal.risha@northeastern.edu

## The assignment was to build Infrastructure for the AWS which includes VPC, Subnets - Public and Private, Route tables, Internet gateway,etc

## Everthing should be such that it should be configured dynamically and minimal manual intervention is to be kept in mind.


## Instructions to run the Assignment

1. Clone the organization's (rishab-csye-6225-cloud-org)  aws-infra (main) repository
2. Go to the aws-infra folder first 
    - terraform init
    - Add the dev.tfvars file (with all the variables) in the root directory
    - terraform plan -var-file="dev.tfvars"
    - terraform apply -var-file="dev.tfvars"
    - terraform destroy -var-file="dev.tfvars"


## Steps followed for the assignment were as follows:
1. Downloaded aws cli for dev and prod profiles to configure aws using both of the credentials of the dev and prod. 
2. Installed terraform in my machine to write IaaC to build the infrastructure as mentioned in the assignment.  

