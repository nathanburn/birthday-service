variable "name" {
  description = "the name of the product / stack e.g. \"demo\""
}

variable "environment" {
  description = "the name of the environment, e.g. \"test\", \"stage\" \"prodution\""
}

variable "application-secrets" {
  description = "A map of secrets that is passed into the application. Formatted like ENV_VAR = VALUE"
  type        = map(any)
}
