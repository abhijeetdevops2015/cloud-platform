resource "aws_security_group" "alb_sg" {
  name   = "${var.project}-${var.environment}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-alb-sg"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb" "app_lb" {
  name               = "${var.project}-${var.environment}-alb"
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]

  subnets = [
    var.public_subnet_1_id,
    var.public_subnet_2_id
  ]

  tags = {
    Name        = "${var.project}-${var.environment}-alb"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.project}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}