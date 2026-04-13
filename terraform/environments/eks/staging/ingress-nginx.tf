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
EOF
  ]

  depends_on = [module.eks]
}
