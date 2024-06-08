module "argocd" {
  source          = "./argocd"
  kubeconfig_path = "~/.kube/config"
  chart_version   = "5.46.0"
  git_source_path    = "k8s-manifests"
  git_source_repoURL = "https://gitlab.se.ifmo.ru/KirillShakhov/devops.labs.deploy"
}

module "prometheus" {
  source          = "./prometheus"
  kubeconfig_path = "~/.kube/config"
}
