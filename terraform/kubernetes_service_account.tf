resource "kubernetes_service_account_v1" "service_account_development" {
  metadata {
    name      = lower(join("-", [local.org_short_name, "kubernetes", "service", "account", kubernetes_namespace_v1.namespace_development.metadata[0].name]))
    namespace = kubernetes_namespace_v1.namespace_development.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.iam_role_development.arn
    }
  }

  depends_on = [
    aws_iam_role.iam_role_development,
    kubernetes_namespace_v1.namespace_development
  ]
}
