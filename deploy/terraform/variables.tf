variable "name" {
  description = "the name of the product / stack e.g. \"demo\""
  default     = "birthday-service"
}

variable "environment" {
  description = "the name of the environment, e.g. \"test\", \"stage\" \"prodution\""
  default     = "test"
}

variable "region" {
  description = "the AWS region e.g. \"eu-west-2\" Europe (London)"
  default     = "eu-west-2"
}

variable "backend_bucket_name" {
  description = "the name of the backend bucket"
  default     = "nab-aws-001-birthday-service-terraform-backend"
}

variable "backend_dynamodb_table_name" {
  description = "the name of the backend dynamo DB table"
  default     = "birthday-service_terraform_state"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["eu-west-2a"] #["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "cidr" {
  description = "the CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.0.0/20", "10.0.32.0/20"] # "10.0.64.0/20"
}

variable "public_subnets" {
  description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.16.0/20", "10.0.48.0/20"] # "10.0.80.0/20"
}

variable "service_desired_count" {
  description = "number of tasks running in parallel"
  default     = 2
}

variable "container_port" {
  description = "the port where the Docker is exposed"
  default     = 8000
}

variable "container_cpu" {
  description = "the number of cpu units used by the task"
  default     = 256
}

variable "container_memory" {
  description = "the amount (in MiB) of memory used by the task"
  default     = 512
}

variable "health_check_path" {
  description = "Http path for task health check /users endpoint"
  default     = "/users"
}

variable "application-secrets" {
  description = "A map of secrets that is passed into the application. Formatted like ENV_VAR = VALUE"
  type        = map(any)
}

#variable "tsl_certificate_arn" {
#  description = "The ARN of the certificate that the ALB uses for https"
#  default = "birthday_service_certificate_arn"
#}

variable "db_username" {
  description = "RDS root username"
  default     = "birthday_service_user"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
