variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format used to scope the OIDC trust policy (e.g. placeholder/cloud-platform)"
  type        = string
}