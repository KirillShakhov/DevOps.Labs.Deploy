output "prometheus_service_endpoint" {
  value = kubernetes_service.prometheus.status[0].load_balancer[0].ingress[0].hostname
}
