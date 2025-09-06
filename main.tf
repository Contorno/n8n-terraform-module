resource "helm_release" "n8n" {
  name       = "n8n"
  repository = "https://community-charts.github.io/helm-charts"
  chart      = "n8n"
  version    = "1.15.4"

  namespace        = kubernetes_namespace.n8n.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      image = {
        repository = "n8nio/n8n"
        tag        = "1.109.2"
        pullPolicy = "IfNotPresent"
      }
      log = {
        level  = "info"
        output = ["console"]
      }
      main = {
        persistence = {
          enabled      = true
          access_mode  = "ReadWriteOnce"
          storageClass = var.storage_class_name
          size         = var.n8n_storage_size
        }
        resources = {
          requests = {
            memory = "512Mi"
            cpu    = "500m"
          }
          limits = {
            memory = "2Gi"
            cpu    = "2000m"
          }
        }
      }
      db = {
        type = "postgresdb"
      }
      postgresql = {
        enabled = true
        primary = {
          persistence = {
            enabled       = true
            size          = "20Gi"
          }
        }
      }
      worker = {
        mode = "regular"
      }
      redis = {
        enabled      = true
        architecture = "standalone"
        master = {
          persistence = {
            enabled = true
            size    = "5Gi"
          }
        }
      }
      webhook = {
        mode = "regular"
        url  = "https://n8n.tail9ae2ce.ts.net/"
      }
      workflowHistory = {
        enabled   = true
        pruneTime = 336
      }
      service = {
        enabled = true
        name    = "http"
        port    = 5678
        type    = "ClusterIP"
      }
      nodeSelector = {
        "kubernetes.io/hostname" = "k8s"
      }
      timezone                    = "America/Los_Angeles"
      existingEncryptionKeySecret = "${kubernetes_secret.n8n_encryption_key.metadata[0].name}"
      ingress = {
        enabled = true
        hosts   = [var.n8n_host]
        className = var.ingress_class_name
      }
    })
  ]

  depends_on = [
    kubernetes_secret.n8n_encryption_key,
    kubernetes_secret.redis,
    kubernetes_persistent_volume_claim.postgresql_data
  ]
}
