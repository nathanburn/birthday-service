# credentials set via Environment variable AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    # note: variable not allowed
    bucket         = "nab-aws-001-birthday-service-terraform-backend"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "birthday-service_terraform_state"
  }
}

module "s3" {
  source      = "./backend/s3"
  bucket_name = var.backend_bucket_name
}

module "dynamodb" {
  source = "./backend/dynamo"
  name   = var.backend_dynamodb_table_name
}

module "iam" {
  source    = "./iam"
  usernames = var.usernames
}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "security_groups" {
  source         = "./security-groups"
  name           = var.name
  vpc_id         = module.vpc.id
  environment    = var.environment
  container_port = var.container_port
}

module "alb" {
  source              = "./alb"
  name                = var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = var.environment
  alb_security_groups = [module.security_groups.alb]
  #alb_tls_cert_arn    = var.tsl_certificate_arn
  health_check_path = var.health_check_path
}

module "ecr" {
  source      = "./ecr"
  name        = var.name
  environment = var.environment
}

module "secrets" {
  source              = "./secrets"
  name                = var.name
  environment         = var.environment
  application-secrets = var.application-secrets
}

module "ecs" {
  source                      = "./ecs"
  name                        = var.name
  environment                 = var.environment
  region                      = var.region
  subnets                     = module.vpc.private_subnets
  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  ecs_service_security_groups = [module.security_groups.ecs_tasks]
  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  container_environment = [
    { name = "LOG_LEVEL",
    value = "DEBUG" },
    { name = "PORT",
    value = var.container_port }
  ]
  container_secrets      = module.secrets.secrets_map
  container_image        = module.ecr.aws_ecr_repository_url
  container_secrets_arns = module.secrets.application_secrets_arn
}

module "rds" {
  source      = "./rds"
  name        = var.name
  environment = var.environment
  vpc_id      = module.vpc.id
  subnets     = module.vpc.public_subnets
  db_username = var.db_username
  db_password = var.db_password
}
