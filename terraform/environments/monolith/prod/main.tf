terraform {
  backend "s3" {
    bucket         = "cloud-platform-terraform-state-abhijeet"
    key            = "terraform/staging/state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  project     = var.project
}

module "alb" {
  source = "../../modules/alb"

  vpc_id             = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id

  environment = var.environment
  project     = var.project
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  vpc_id           = module.vpc.vpc_id
  alb_sg_id        = module.alb.alb_sg_id
  target_group_arn = module.alb.target_group_arn

  private_subnets = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  environment = var.environment
  project     = var.project
}