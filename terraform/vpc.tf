module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name = lower(join("-", [local.org_short_name, "vpc"]))
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 4)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 8)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k + 12)]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  manage_default_network_acl = true
  default_network_acl_tags = merge(module.tags.tags, {
    Name = lower(join("-", [local.org_short_name, "network", "acl"]))
  })

  manage_default_route_table = true
  default_route_table_tags = merge(module.tags.tags, {
    Name = lower(join("-", [local.org_short_name, "route", "table"]))
  })

  manage_default_security_group = true
  default_security_group_tags = {
    Name = "${local.name}-security-group",
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = module.tags.tags
}
