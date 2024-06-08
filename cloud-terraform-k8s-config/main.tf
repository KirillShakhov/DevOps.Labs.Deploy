module "argocd" {
  source          = "./argocd"
  kubeconfig_path = "./kubeconfig"
  chart_version   = "5.46.0"
}

module "argocd_dev_root" {
  source             = "./argocd-root"
  kubeconfig_path    = "./kubeconfig"
  git_source_path    = "demo-dev/applications"
  git_source_repoURL = "git@github.com:adv4000/argocd.git"
}

module "prometheus" {
  source          = "./prometheus"
  kubeconfig_path = "./kubeconfig"
}
