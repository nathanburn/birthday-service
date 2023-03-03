# create RDS for PostgreSQL DB

resource "aws_db_subnet_group" "rds" {
  name       = "${var.name}-db-subnet-group-rds-${var.environment}"
  subnet_ids = var.subnets.*.id

  tags = {
    Name        = "${var.name}-db-subnet-group-rds-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.name}-sg-rds-${var.environment}"
  vpc_id = var.vpc_id

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
    Name        = "${var.name}-sg-rds-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.name}-db-${var.environment}"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.name}-db-${var.environment}"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "13"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
