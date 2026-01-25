terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# DB Subnet Group (use your existing private subnets from VPC layer)
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# DB Security Group (allow MySQL only from app SG)
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allow MySQL access from App SG"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# Store DB password in SSM Parameter Store (SecureString)
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db/password"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Project = var.project_name
  }
}

# RDS MySQL instance
resource "aws_db_instance" "mariaDB" {
  identifier              = "${var.project_name}-app-db"
  engine                  = "mysql"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp3"

  db_name                 = var.db_name
  username                = var.db_username
  password                = aws_ssm_parameter.db_password.value

  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]

  publicly_accessible     = false
  multi_az                = var.db_multi_az
  skip_final_snapshot     = true
  deletion_protection     = false

  backup_retention_period = var.db_backup_retention
  backup_window           = var.db_backup_window
  maintenance_window      = var.db_maintenance_window

  auto_minor_version_upgrade = true

  tags = {
    Name    = "${var.project_name}-app-db"
    Project = var.project_name
    Env     = var.environment
  }
}
