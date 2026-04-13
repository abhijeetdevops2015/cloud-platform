###############################################################
# INSTALL ARGOCD
#
# ArgoCD is installed independently on each cluster.
# Each cluster (dev/staging/prod) manages its own ArgoCD
# instance and its own ArgoCD Application.
#
# The argocd-install.yaml is shared from dev:
#   file("../dev/argocd-install.yaml")
# Or symlink it:
#   ln -s ../dev/argocd-install.yaml argocd-install.yaml
###############################################################

resource "null_resource" "argocd_install" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
        --region us-east-1 \
        --name ${module.eks.cluster_name} \
        --kubeconfig /tmp/kubeconfig-staging

      kubectl create namespace argocd \
        --kubeconfig /tmp/kubeconfig-staging \
        --dry-run=client -o yaml \
        | kubectl apply --kubeconfig /tmp/kubeconfig-staging -f -

      kubectl apply \
        --server-side \
        --force-conflicts \
        --kubeconfig /tmp/kubeconfig-staging \
        -n argocd \
        -f ${path.module}/../dev/argocd-install.yaml
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
        --kubeconfig /tmp/kubeconfig-staging \
        --for=condition=available \
        --timeout=300s \
        deployment/argocd-server \
        -n argocd
    EOT
  }

  depends_on = [null_resource.argocd_install]
}

###############################################################
# ARGOCD APPLICATION — staging
#
# Points at kubernetes/overlays/staging.
# Auto-sync is enabled so any merge to main that updates the
# staging overlay (e.g. a promoted image SHA) deploys automatically.
#
# Real-world note: some teams disable automated sync for staging
# and use a manual promotion step. To do that, remove the
# `automated` block and sync via:
#   argocd app sync cloud-platform-staging
###############################################################

resource "kubectl_manifest" "argocd_app" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: cloud-platform-staging
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default

      source:
        repoURL: https://github.com/abhijeetdevops2015/cloud-platform
        targetRevision: main
        path: kubernetes/overlays/staging

      destination:
        server: https://kubernetes.default.svc
        namespace: cloud-platform-staging

      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=false
          - PrunePropagationPolicy=foreground
          - PruneLast=true
  YAML

  depends_on = [null_resource.wait_for_argocd]
}
