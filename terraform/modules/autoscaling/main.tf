resource "aws_security_group" "ec2_sg" {
  name   = "${var.project}-${var.environment}-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-sg"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.project}-${var.environment}-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "${var.project}-${var.environment}-template"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
docker run -d -p 80:80 nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project}-${var.environment}-ec2"
      Environment = var.environment
      Project     = var.project
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2

  vpc_zone_identifier = var.private_subnets

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-ec2"
    propagate_at_launch = true
  }
}