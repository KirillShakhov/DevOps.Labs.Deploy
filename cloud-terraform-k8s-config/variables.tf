variable "kubeconfig_path" {
  type    = string
  default = "./kubeconfig"  # Укажите путь к вашему файлу kubeconfig
}

variable "chart_version" {
  description = "Helm Chart Version of ArgoCD: https://github.com/argoproj/argo-helm/releases"
  type        = string
  default     = "5.46.0"
}

variable "git_source_repoURL" {
  description = "GitSource repoURL to Track and deploy to EKS by ROOT Application"
  type        = string
  default     = "https://gitlab.se.ifmo.ru/KirillShakhov/devops.labs.deploy.git"
}

variable "git_source_path" {
  description = "GitSource Path in Git Repository to Track and deploy to EKS by ROOT Application"
  type        = string
  default     = "k8s-manifests"
}

variable "git_source_targetRevision" {
  description = "GitSource HEAD or Branch to Track and deploy to EKS by ROOT Application"
  type        = string
  default     = "HEAD"
}