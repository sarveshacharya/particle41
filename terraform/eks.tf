module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = lower(join("-", [local.org_short_name, "eks"]))
  kubernetes_version = "1.33"

  addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  endpoint_private_access                  = true

  endpoint_public_access = true
  endpoint_public_access_cidrs = [
    "124.253.66.152/32"
  ]

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  tags = module.tags.tags

  depends_on = [module.vpc]
}
