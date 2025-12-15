resource "aws_iam_role" "iam_role_development" {
  name = lower(join("-", [local.org_short_name, "iam", "role", "development"]))

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${local.region}.amazonaws.com/id/37CF7C36EFC4A3B2C4FF45CE52D1F8C9"
        }
        Condition = {
          StringEquals = {
            "oidc.eks.${local.region}.amazonaws.com/id/37CF7C36EFC4A3B2C4FF45CE52D1F8C9:sub" = "system:serviceaccount:${kubernetes_namespace_v1.namespace_development.metadata[0].name}:${lower(join("-", [local.org_short_name, "kubernetes", "service", "account", kubernetes_namespace_v1.namespace_development.metadata[0].name]))}"
          }
        }
      }
    ]
  })

  depends_on = [
    kubernetes_namespace_v1.namespace_development
  ]
}
