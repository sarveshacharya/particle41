resource "kubernetes_namespace_v1" "namespace_development" {
  metadata {
    name = "development"
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [module.eks]
}
