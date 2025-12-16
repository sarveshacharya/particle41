resource "kubernetes_namespace_v1" "namespace_development" {
  metadata {
    name = "development"
  }

  depends_on = [module.eks]
}
