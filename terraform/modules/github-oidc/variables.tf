variable "project" {
  description = "Project name — used to name IAM resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format (e.g. placeholder/cloud-platform). Used to scope the OIDC trust policy so only this repo can assume the IAM roles."
  type        = string
}
