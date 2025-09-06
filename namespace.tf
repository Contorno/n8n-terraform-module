resource "kubernetes_namespace" "n8n" {
  metadata {
    name = var.namespace_name
    labels = {
      name                                 = var.namespace_name
      "pod-security.kubernetes.io/enforce" = "baseline"
      "pod-security.kubernetes.io/audit"   = "baseline"
      "pod-security.kubernetes.io/warn"    = "baseline"
    }
  }
}