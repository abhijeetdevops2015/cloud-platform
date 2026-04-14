resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.15.1"   # 🔥 lock version (avoids random failures)

  timeout = 600           # 🔥 avoid timeout issues

  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
EOF
  ]
}