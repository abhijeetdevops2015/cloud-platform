###############################################################
# APP NAMESPACE + DB CREDENTIALS SECRET
#
# Creates the cloud-platform-dev namespace and the db-credentials
# secret that backend pods require at startup.
#
# Managed here in Terraform so that every `terraform apply`
# (including after a destroy) recreates these automatically —
# no manual kubectl commands needed.
#
# Values come directly from existing Terraform inputs:
#   - db-host     → module.rds.db_endpoint (port stripped)
#   - db-password → var.db_password (already a sensitive var)
###############################################################

# Create the namespace before the secret so the secret has
# somewhere to live. ArgoCD also applies namespace.yaml from
# the overlay — Kubernetes handles the "already exists" case
# gracefully so there is no conflict.
resource "kubectl_manifest" "app_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: cloud-platform-dev
  YAML

  depends_on = [module.eks]
}

# db-credentials secret consumed by the backend Deployment via
# secretKeyRef in kubernetes/base/backend.yaml.
# The RDS endpoint output includes ":5432" — split() strips the
# port so db-host contains only the hostname.
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = "cloud-platform-dev"
  }

  data = {
    db-host     = split(":", module.rds.db_endpoint)[0]
    db-user     = "postgres"
    db-password = var.db_password
    db-name     = "appdb"
  }

  depends_on = [kubectl_manifest.app_namespace]
}
