terraform {
  backend "s3" {
    bucket         = "cloud-platform-terraform-state-abhijeet"
    key            = "terraform/eks/dev/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

# -------------------------
# AWS Provider
# -------------------------
provider "aws" {
  region = "us-east-1"
}

# -------------------------
# VPC Module
# -------------------------
module "vpc" {
  source = "../../../modules/vpc"

  environment = var.environment
  project     = var.project
}

# -------------------------
# EKS Module
# -------------------------
module "eks" {
  source = "../../../modules/eks"

  cluster_name = "${var.project}-${var.environment}-eks"

  vpc_id = module.vpc.vpc_id

  private_subnets = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  environment = var.environment
  project     = var.project
}

# -------------------------
# ECR Module
# -------------------------
module "ecr" {
  source = "../../../modules/ecr"

  environment = var.environment
  project     = var.project
}

# -------------------------
# RDS Module
# -------------------------
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

# -------------------------
# GitHub OIDC Module
# -------------------------
module "github_oidc" {
  source = "../../../modules/github-oidc"

  project     = var.project
  environment = var.environment
  github_repo = var.github_repo
}