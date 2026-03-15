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