terraform {
  backend "s3" {
    bucket         = "cloud-platform-terraform-state-abhijeet"
    key            = "terraform/eks/staging/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../../modules/vpc"

  environment = var.environment
  project     = var.project
}

module "eks" {
  source = "../../../modules/eks"

  vpc_id = module.vpc.vpc_id

  private_subnets = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  environment = var.environment
  project     = var.project
}

module "ecr" {
  source = "../../../modules/ecr"

  environment = var.environment
  project     = var.project
}

module "rds" {
  source = "../../../modules/rds"

  environment = var.environment
  project     = var.project

  vpc_id = module.vpc.vpc_id

  private_subnets = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  eks_node_sg = module.eks.cluster_security_group_id

  db_password = var.db_password
}