# Get secrets from Infisical
data "infisical_secrets" "n8n_secrets" {
  env_slug     = var.infisical_env_slug
  workspace_id = var.infisical_workspace_id
  folder_path  = var.infisical_folder_path
}

resource "kubernetes_secret" "n8n" {
  metadata {
    name      = "${var.name}-secret"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = "n8n"
    }
  }

  data = {
    "N8N_ENCRYPTION_KEY" = data.infisical_secrets.n8n_secrets.secrets["N8N_ENCRYPTION_KEY"].value
  }

  type = "Opaque"

  lifecycle {
    prevent_destroy = true
  }
}