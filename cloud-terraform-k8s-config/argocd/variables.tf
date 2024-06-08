variable "kubeconfig_path" {
  type    = string
  default = "./kubeconfig"  # Укажите путь к вашему файлу kubeconfig
}

variable "chart_version" {
  description = "Helm Chart Version of ArgoCD: https://github.com/argoproj/argo-helm/releases"
  type        = string
  default     = "5.46.0"
}

variable "git_repo_url" {
  description = "URL of the Git repository"
  type        = string
  default     = ""
}

variable "repo_path" {
  description = "Path to the folder in the Git repository"
  type        = string
  default     = ""
}