###############################################################
# APP NAMESPACE + DB CREDENTIALS SECRET — prod
#
# Recreated automatically on every terraform apply so no manual
# kubectl commands are needed after a destroy + apply cycle.
###############################################################

resource "kubectl_manifest" "app_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: cloud-platform-prod
  YAML

  depends_on = [module.eks]
}

resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = "cloud-platform-prod"
  }

  data = {
    db-host     = split(":", module.rds.db_endpoint)[0]
    db-user     = "postgres"
    db-password = var.db_password
    db-name     = "appdb"
  }

  depends_on = [kubectl_manifest.app_namespace]
}
