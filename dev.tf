variable "region" {
  type        = string
  description = "specifies the region where to run the config file"

}

variable "profile" {
  type        = string
  description = "specify the profile to use for accessing the aws"

}

variable "vpc_cidr" {
  type        = string
  description = "vpc's cidr range in the particular region"

}

variable "assignment" {
  type        = string
  description = "this is the prefix of the tag value which we provide to resources"

}


variable "state" {
  type        = string
  description = "the state of the availability zone"

}

variable "internet_gateway_cidr" {
  type        = string
  description = "internet gateway cidr range"

}

variable "public_subnet_cidr_list" {
  type        = list(any)
  description = "a list of all public subnet cidr values"
}


variable "private_subnet_cidr_list" {
  type        = list(any)
  description = "a list of all private subnet cidr values"

}