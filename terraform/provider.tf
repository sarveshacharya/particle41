###############################################################################
# Common Locals
###############################################################################
data "aws_availability_zones" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  name           = "Particle41"
  region         = data.aws_region.current.region
  org_short_name = "p41"
  environment    = "prod"

  # VPC
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.current.names, 0, 2)

  cluster_version = "1.33"
}

provider "aws" {
  region = "us-east-2"

  shared_config_files      = ["/Users/sarveshacharya/.aws/config"]
  shared_credentials_files = ["/Users/sarveshacharya/.aws/credentials"]
  profile                  = "news"

  default_tags {
    tags = {
      Application = local.name
      Environment = local.environment
    }
  }
}

data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.vpc]
}
data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.vpc]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubectl" {
  apply_retry_count = 5

  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

  load_config_file = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# # ###############################################################################
# # Common Modules
# # ###############################################################################

module "tags" {
  source  = "clowdhaus/tags/aws"
  version = "1.2.0"

  application = local.name
  environment = local.environment
  repository  = "https://github.com/x-arterian/cb-devops-terraform-aws/"
}
