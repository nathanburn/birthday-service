variable "name" {
  description = "the name of the product / stack e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"test\", \"stage\" \"prodution\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "container_port" {
  description = "Ingres and egress port of the container"
}
