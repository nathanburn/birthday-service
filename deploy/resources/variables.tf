variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "db_password" {
  default     = "birthday-service-password"
  description = "RDS root user password"
  sensitive   = true
}
