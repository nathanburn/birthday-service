provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "birthday_service"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "birthday_service" {
  name       = "birthday-service"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "birthday-service"
  }
}

resource "aws_security_group" "rds" {
  name   = "birthday_service_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "birthday_service_rds"
  }
}

resource "aws_db_parameter_group" "birthday_service" {
  name   = "birthday-service"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "birthday_service" {
  identifier             = "birthday-service"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13.1"
  username               = "birthday-service-user"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.birthday_service.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.birthday_service.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
