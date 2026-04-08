output "ci_role_arn" {
  description = "ARN of the CI IAM role — store this as GitHub secret AWS_ROLE_ARN_CI"
  value       = aws_iam_role.github_actions_ci.arn
}

output "terraform_role_arn" {
  description = "ARN of the Terraform IAM role — store this as GitHub secret AWS_ROLE_ARN_TERRAFORM"
  value       = aws_iam_role.github_actions_terraform.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (account-level)"
  value       = aws_iam_openid_connect_provider.github.arn
}
