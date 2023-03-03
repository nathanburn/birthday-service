variable "name" {
  description = "the name of the product / stack e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"test\", \"stage\" \"prodution\""
}

variable "subnets" {
  description = "Comma separated list of subnet IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "db_username" {
  description = "RDS root username"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
