variable "environment" {
  type    = string
  default = "staging"
}

variable "project" {
  type    = string
  default = "cloud-platform"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format (e.g. abhijeetdevops2015/cloud-platform)"
  type        = string
  default     = "abhijeetdevops2015/cloud-platform"
}

# -------------------------------------------------------
# Staging sizing — slightly larger than dev, smaller than prod
# -------------------------------------------------------

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "allocated_storage" {
  type    = number
  default = 20
}
