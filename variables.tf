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
  default     = "/"
}

variable "namespace_name" {
  description = "Name of the Kubernetes namespace"
  type        = string
  default     = "n8n"
}

variable "name" {
    description = "Module name"
    type        = string
    default     = "n8n"
}

variable "n8n_version" {
  description = "n8n Docker image version"
  type        = string
  default     = "latest"
}

variable "n8n_replicas" {
  description = "Number of n8n replicas"
  type        = number
  default     = 1
}

variable "n8n_host" {
  description = "Hostname for n8n"
  type        = string
}

variable "timezone" {
  description = "Timezone for n8n"
  type        = string
  default     = "America/Los_Angeles"
}

variable "n8n_storage_size" {
  description = "Storage size for n8n data"
  type        = string
  default     = "50Gi"
}

variable "storage_class_name" {
  description = "Storage class name"
  type        = string
  default     = "default"
}

variable "n8n_memory_request" {
  description = "Memory request for n8n"
  type        = string
  default     = "512Mi"
}

variable "n8n_memory_limit" {
  description = "Memory limit for n8n"
  type        = string
  default     = "2Gi"
}

variable "n8n_cpu_request" {
  description = "CPU request for n8n"
  type        = string
  default     = "250m"
}

variable "n8n_cpu_limit" {
  description = "CPU limit for n8n"
  type        = string
  default     = "1000m"
}

variable "ingress_annotations" {
  description = "Ingress annotations"
  type        = map(string)
  default     = {}
}

variable "postgresql_storage_size" {
  description = "Size of the persistent volume claim for PostgreSQL."
  type        = string
  default     = "10Gi"
}

variable "postgresql_memory_limit" {
  description = "Memory limit for the PostgreSQL container."
  type        = string
  default     = "4Gi"
}

variable "postgresql_cpu_request" {
  description = "CPU request for the PostgreSQL container."
  type        = string
  default     = "1000m"
}

variable "postgresql_memory_request" {
  description = "Memory request for the PostgreSQL container."
  type        = string
  default     = "1000Mi"
}

variable "postgresql_cpu_limit" {
  description = "CPU limit for the PostgreSQL container."
  type        = string
  default     = "4000m"
}

variable "postgresql_version" {
  description = "PostgreSQL image version tag."
  type        = string
  default     = "17"
}