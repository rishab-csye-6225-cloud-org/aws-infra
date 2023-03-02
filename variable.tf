variable "region" {
  type        = string
  description = "specifies the region where to run the config file"
  default     = "us-west-1"
}

variable "profile" {
  type        = string
  description = "specify the profile to use for accessing the aws"
  default     = "dev"

}

variable "vpc_cidr" {
  type        = string
  description = "vpc's cidr range in the particular region"
  default     = "152.0.0.0/16"

}

variable "assignment" {
  type        = string
  description = "this is the prefix of the tag value which we provide to resources"
  default     = "Assignment"

}


variable "state" {
  type        = string
  description = "the state of the availability zone"
  default     = "available"

}

variable "internet_gateway_cidr" {
  type        = string
  description = "internet gateway cidr range"
  default     = "0.0.0.0/0"

}

variable "public_subnet_cidr_list" {
  type        = list(string)
  description = "a list of all public subnet cidr values"
  default     = ["152.0.1.0/24", "152.0.2.0/24", "152.0.3.0/24"]
}


variable "private_subnet_cidr_list" {
  type        = list(string)
  description = "a list of all private subnet cidr values"
  default     = ["152.0.4.0/24", "152.0.5.0/24", "152.0.6.0/24"]

}


variable "map_public_ip" {
  type        = bool
  description = "public ip is assigned when the subnet is created"
  default     = true

}


variable "app_port" {
  type        = number
  description = "application port"
  default     = 9001

}


variable "ssh_key_name" {
  type        = string
  description = "ssh key name"
  default     = "xxx"

}

variable "ami_owners" {
  type        = list(string)
  description = "a list of all private subnet cidr values"
  default     = ["xxx"]

}



variable "db_password" {
  type        = string
  description = "database password"
  default     = ""
}

variable "db_name" {
  type        = string
  description = "database name"
  default     = ""
}

variable "db_user" {
  type        = string
  description = "database user name"
  default     = ""
}