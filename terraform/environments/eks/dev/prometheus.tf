###############################################################
# OBSERVABILITY — kube-prometheus-stack (FINAL STABLE)
###############################################################

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "observability"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "69.3.2"

  timeout = 600
  wait    = false
  atomic  = false

  values = [
    <<-EOT
    ###########################################################
    # PROMETHEUS
    ###########################################################
    prometheus:
      prometheusSpec:
        serviceMonitorSelectorNilUsesHelmValues: false
        podMonitorSelectorNilUsesHelmValues: false
        retention: 15d
        retentionSize: 10GB
        storageSpec: {}
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi

    ###########################################################
    # GRAFANA (SUBPATH — /grafana)
    # Served at /grafana so the app frontend at / is unaffected.
    # root_url tells Grafana its public URL so redirects and asset
    # URLs are correct. serve_from_sub_path strips the prefix
    # before Grafana processes the request.
    # The regex path + $2 rewrite passes only the suffix to Grafana
    # e.g. /grafana/login → /login, /grafana → /
    ###########################################################
    grafana:
      adminUser: admin
      adminPassword: admin123

      grafana.ini:
        server:
          root_url: "http://afa229b779a534428a5edc9af5049b45-365764994.us-east-1.elb.amazonaws.com/grafana"
          serve_from_sub_path: true

      ingress:
        enabled: true
        ingressClassName: nginx
        # No rewrite-target — serve_from_sub_path: true means Grafana
        # strips the /grafana prefix itself. Adding a rewrite here
        # causes a redirect loop (both sides try to handle the prefix).
        path: /grafana
        pathType: Prefix

      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 200m
          memory: 256Mi

      persistence:
        enabled: false

      defaultDashboardsEnabled: true

    ###########################################################
    # ALERTMANAGER
    ###########################################################
    alertmanager:
      alertmanagerSpec:
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 100m
            memory: 128Mi

    ###########################################################
    # NODE EXPORTER
    ###########################################################
    nodeExporter:
      enabled: true

    prometheus-node-exporter:
      resources:
        requests:
          cpu: 50m
          memory: 32Mi
        limits:
          cpu: 100m
          memory: 64Mi

    ###########################################################
    # KUBE STATE METRICS
    ###########################################################
    kubeStateMetrics:
      enabled: true

    kube-state-metrics:
      resources:
        requests:
          cpu: 50m
          memory: 64Mi
        limits:
          cpu: 100m
          memory: 128Mi

    ###########################################################
    # EKS CONTROL PLANE SETTINGS
    ###########################################################
    kubeEtcd:
      enabled: false

    kubeScheduler:
      enabled: false

    kubeControllerManager:
      enabled: false

    kubeApiServer:
      enabled: true

    kubelet:
      enabled: true

    kubeProxy:
      enabled: true
    EOT
  ]

  depends_on = [
    module.eks,
    helm_release.nginx_ingress
  ]
}