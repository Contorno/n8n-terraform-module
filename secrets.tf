ephemeral "infisical_secret" "n8n_encryption_key" {
  name         = "N8N_ENCRYPTION_KEY"
  env_slug     = var.infisical_env_slug
  workspace_id = var.infisical_workspace_id
  folder_path  = var.infisical_folder_path
}

locals {
  n8n_encryption_key = ephemeral.infisical_secret.n8n_encryption_key.value
}

resource "kubernetes_secret" "n8n" {
  metadata {
    name      = "${var.namespace_name}-secret"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n"
    }
  }

  data = {
    "N8N_ENCRYPTION_KEY" = local.n8n_encryption_key
  }

  type = "Opaque"

  lifecycle {
    prevent_destroy = true
  }
}