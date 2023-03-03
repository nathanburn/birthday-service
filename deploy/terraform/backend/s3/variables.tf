variable "bucket_name" {
  description = "the name of the bucket"
}

variable "acl_value" {
  description = "the ACL configuration"
  default     = "private"
}
