variable "name" {
  description = "the name of the product / stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"prod\""
}

variable "cidr" {
  description = "the CIDR block for the VPC"
}

variable "public_subnets" {
  description = "list of public subnets"
}

variable "private_subnets" {
  description = "list of private subnets"
}

variable "availability_zones" {
  description = "list of availability zones"
}
