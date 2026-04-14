###############################################################
# INSTALL ARGOCD
###############################################################

resource "null_resource" "argocd_install" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
        --region us-east-1 \
        --name ${module.eks.cluster_name} \
        --kubeconfig /tmp/kubeconfig-dev

      kubectl create namespace argocd \
        --kubeconfig /tmp/kubeconfig-dev \
        --dry-run=client -o yaml \
        | kubectl apply --kubeconfig /tmp/kubeconfig-dev -f -

      kubectl apply \
        --server-side \
        --force-conflicts \
        --kubeconfig /tmp/kubeconfig-dev \
        -n argocd \
        -f ${path.module}/argocd-install.yaml
    EOT
  }

  depends_on = [module.eks]
}

###############################################################
# WAIT FOR ARGOCD TO BE READY
###############################################################

resource "null_resource" "wait_for_argocd" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait \
        --kubeconfig /tmp/kubeconfig-dev \
        --for=condition=available \
        --timeout=300s \
        deployment/argocd-server \
        -n argocd
    EOT
  }

  depends_on = [null_resource.argocd_install]
}

###############################################################
# ARGOCD APPLICATION — dev (FINAL FIX)
###############################################################

resource "null_resource" "argocd_app" {
  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF | kubectl apply --kubeconfig /tmp/kubeconfig-dev -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cloud-platform-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io

spec:
  project: default

  source:
    repoURL: https://github.com/abhijeetdevops2015/cloud-platform
    targetRevision: main
    path: kubernetes/overlays/dev

  destination:
    server: https://kubernetes.default.svc
    namespace: cloud-platform-dev

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
      - PrunePropagationPolicy=foreground
      - PruneLast=true
EOF
    EOT
  }

  depends_on = [
    null_resource.wait_for_argocd
  ]
}