# GitHub Actions OIDC Provider
# This is an account-level resource — it only needs to be created once per AWS account.
# If you already have an OIDC provider for GitHub in this account, import it instead:
#   terraform import aws_iam_openid_connect_provider.github <arn>
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC CA thumbprint — stable, published by GitHub
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# ── CI Role ────────────────────────────────────────────────────────────────────
# Used by backend.yml and frontend.yml to push images to ECR.
# Trust is restricted to pushes on the main branch of the specific repo.
resource "aws_iam_role" "github_actions_ci" {
  name = "${var.project}-${var.environment}-github-actions-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Only tokens from main branch pushes can assume this role
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "github_actions_ci" {
  name = "${var.project}-${var.environment}-github-actions-ci"
  role = aws_iam_role.github_actions_ci.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # GetAuthorizationToken is a global call — cannot be scoped to a resource
        Sid    = "ECRAuth"
        Effect = "Allow"
        Action = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        # Push operations scoped to this project's repositories only
        Sid    = "ECRPush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "arn:aws:ecr:*:*:repository/${var.project}-${var.environment}-*"
      },
      {
        # Allows workflows to describe the cluster (e.g. for kubectl context setup)
        Sid      = "EKSRead"
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "*"
      }
    ]
  })
}

# ── Terraform Role ─────────────────────────────────────────────────────────────
# Used by terraform.yml to run plan and apply.
# Trust allows both push (apply) and pull_request (plan) events from the repo.
resource "aws_iam_role" "github_actions_terraform" {
  name = "${var.project}-${var.environment}-github-actions-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Wildcard ref allows both branch pushes and PR events
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "github_actions_terraform" {
  name = "${var.project}-${var.environment}-github-actions-terraform"
  role = aws_iam_role.github_actions_terraform.id

  # Scope: all services this project's Terraform touches.
  # Tighten Resource ARNs further once infrastructure is stable.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VPC"
        Effect = "Allow"
        Action = ["ec2:*"]
        Resource = "*"
      },
      {
        Sid    = "EKS"
        Effect = "Allow"
        Action = ["eks:*"]
        Resource = "*"
      },
      {
        Sid    = "RDS"
        Effect = "Allow"
        Action = ["rds:*"]
        Resource = "*"
      },
      {
        Sid    = "ECR"
        Effect = "Allow"
        Action = ["ecr:*"]
        Resource = "*"
      },
      {
        Sid    = "IAM"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider"
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformState"
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::cloud-platform-terraform-state-abhijeet",
          "arn:aws:s3:::cloud-platform-terraform-state-abhijeet/*"
        ]
      },
      {
        Sid    = "TerraformLocks"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/terraform-locks"
      },
      {
        Sid    = "ELB"
        Effect = "Allow"
        Action = ["elasticloadbalancing:*"]
        Resource = "*"
      },
      {
        Sid    = "AutoScaling"
        Effect = "Allow"
        Action = ["autoscaling:*"]
        Resource = "*"
      }
    ]
  })
}
