output "kubernetes_ingress_development" {
  value = kubernetes_ingress_v1.ingress_development.status[0].load_balancer[0].ingress[0].hostname
}
