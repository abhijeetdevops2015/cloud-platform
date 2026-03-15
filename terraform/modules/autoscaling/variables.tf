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