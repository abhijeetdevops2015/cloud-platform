output "db_endpoint" {
  value = module.rds.db_endpoint
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "ecr_backend_repo" {
  value = module.ecr.backend_repo_url
}

output "ecr_frontend_repo" {
  value = module.ecr.frontend_repo_url
}

output "github_actions_ci_role_arn" {
  description = "Copy this value into GitHub secret: AWS_ROLE_ARN_CI"
  value       = module.github_oidc.ci_role_arn
}

output "github_actions_terraform_role_arn" {
  description = "Copy this value into GitHub secret: AWS_ROLE_ARN_TERRAFORM"
  value       = module.github_oidc.terraform_role_arn
}