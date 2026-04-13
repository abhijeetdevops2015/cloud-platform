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

# -------------------------------------------------------
# DB sizing — vary per environment without code changes
# -------------------------------------------------------

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro" # dev default; prod should use db.t3.small or larger
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}
