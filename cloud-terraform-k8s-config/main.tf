module "argocd" {
  source          = "./argocd"
  kubeconfig_path = "./kubeconfig"
  chart_version   = "5.46.0"
}

module "argocd_dev_root" {
  source             = "./argocd-root"
  kubeconfig_path    = "./kubeconfig"
  git_source_path    = "k8s-manifests"
  git_source_repoURL = "https://gitlab.se.ifmo.ru/KirillShakhov/devops.labs.deploy"

  depends_on = [module.argocd]
}

module "prometheus" {
  source          = "./prometheus"
  kubeconfig_path = "./kubeconfig"
}
