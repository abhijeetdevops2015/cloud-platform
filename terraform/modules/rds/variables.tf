variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "eks_node_sg" {
  type = string
}

variable "db_password" {
  type = string
}