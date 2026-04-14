resource "aws_ecr_repository" "backend" {
  name         = "${var.project}-${var.environment}-backend"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_ecr_repository" "frontend" {
  name         = "${var.project}-${var.environment}-frontend"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}