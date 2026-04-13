resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
  replicaCount: 2
EOF
  ]

  depends_on = [module.eks]
}
