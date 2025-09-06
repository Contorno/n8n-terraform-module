variable "infisical_env_slug" {
  description = "Infisical environment slug"
  type        = string
}

variable "infisical_workspace_id" {
  description = "Infisical workspace id" 
  type        = string
}

variable "infisical_folder_path" {
  description = "Infisical folder path for secrets"
  type        = string
  default     = "/n8n"
}

variable "namespace_name" {
    description = "Module name"
    type        = string
    default     = "n8n"
}

variable "n8n_storage_size" {
  description = "Storage size for n8n data"
  type        = string
  default     = "50Gi"
}

variable "storage_class_name" {
  description = "Storage class name"
  type        = string
  default     = "k8s-hostpath"
}

variable "ingress_class_name" {
    description = "Ingress class name"
    type        = string
    default     = "tailscale"
}