resource "aws_ecr_repository" "backend" {
  name = "${var.project}-${var.environment}-backend"

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
  name = "${var.project}-${var.environment}-frontend"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}