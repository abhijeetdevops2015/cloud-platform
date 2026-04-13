###############################################################
# INSTALL ARGOCD
#
# ArgoCD is installed independently on the prod cluster.
# Shares the same install manifest as dev.
###############################################################

resource "null_resource" "argocd_install" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
        --region us-east-1 \
        --name ${module.eks.cluster_name} \
        --kubeconfig /tmp/kubeconfig-prod

      kubectl create namespace argocd \
        --kubeconfig /tmp/kubeconfig-prod \
        --dry-run=client -o yaml \
        | kubectl apply --kubeconfig /tmp/kubeconfig-prod -f -

      kubectl apply \
        --server-side \
        --force-conflicts \
        --kubeconfig /tmp/kubeconfig-prod \
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
        --kubeconfig /tmp/kubeconfig-prod \
        --for=condition=available \
        --timeout=300s \
        deployment/argocd-server \
        -n argocd
    EOT
  }

  depends_on = [null_resource.argocd_install]
}

###############################################################
# ARGOCD APPLICATION — prod
#
# Points at kubernetes/overlays/prod.
# Auto-sync is enabled so an approved image promotion (merged
# to main) deploys automatically to prod.
#
# Real-world note: production often disables automated sync
# and requires a manual `argocd app sync` after human review.
# To switch to manual sync, remove the `automated` block below.
###############################################################

resource "kubectl_manifest" "argocd_app" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: cloud-platform-prod
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default

      source:
        repoURL: https://github.com/abhijeetdevops2015/cloud-platform
        targetRevision: main
        path: kubernetes/overlays/prod

      destination:
        server: https://kubernetes.default.svc
        namespace: cloud-platform-prod

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
