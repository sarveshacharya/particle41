################################################################################
# ALB Controller - IAM role for Service Accounts
################################################################################

module "alb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.58.0"

  role_name              = lower(join("-", [local.org_short_name, "alb", "controller", "role"]))
  allow_self_assume_role = true

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  depends_on = [module.eks]

  tags = module.tags.tags
}

################################################################################
# ALB Controller - Helm Chart
################################################################################

resource "helm_release" "alb_controller" {
  namespace = "kube-system"

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.2"

  values = [
    <<-EOT
    clusterName: ${module.eks.cluster_name}
    region: ${local.region}
    vpcId: ${module.vpc.vpc_id}

    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.alb_controller_irsa.iam_role_arn}
    EOT
  ]
}
