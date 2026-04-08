variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block permitted to reach EC2 instances on SSH port 22. Defaults to the VPC CIDR — never use 0.0.0.0/0 in production."
  type        = string
  default     = "10.0.0.0/16"
}