variable "kubeconfig_path" {
  type    = string
  default = "${path.module}/kubeconfig"  # Укажите путь к вашему файлу kubeconfig
}
