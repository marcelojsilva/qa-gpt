
variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy the infrastructure in"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The list of private subnet IDs to deploy the RDS instance in"
}

variable "app_sg_id" {
  type        = string
  description = "The security group ID of the application"
}

resource "aws_db_instance" "main" {
  identifier = "${var.app_name}-db"
  engine     = "postgres"
  engine_version    = "13.3"
  skip_final_snapshot       = true
  # final_snapshot_identifier = "your-final-snapshot-name" # Uncomment this line and provide a snapshot name if you want to create a final snapshot

  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  storage_type               = "gp2"
  auto_minor_version_upgrade = true
  backup_retention_period    = 7
  storage_encrypted          = true

  username = "appuser"
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  multi_az            = false
  publicly_accessible = false

  parameter_group_name = aws_db_parameter_group.main.name

  tags = {
    Name = "${var.app_name}-db"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.app_name}-db-sg"
  description = "Allow inbound traffic to the RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  tags = {
    Name = "${var.app_name}-db-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.app_name}-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.app_name}-db-pg"
  family = "postgres13"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "${var.app_name}-db-pg"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

output "db_instance_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}