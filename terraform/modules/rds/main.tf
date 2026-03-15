resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.project}-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnets

  tags = {
    Name        = "${var.project}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "${var.project}-${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_sg]
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project}-${var.environment}-postgres"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "appdb"
  username = "postgres"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  skip_final_snapshot = true

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}