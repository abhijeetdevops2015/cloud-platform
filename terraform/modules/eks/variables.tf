variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for worker nodes"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}