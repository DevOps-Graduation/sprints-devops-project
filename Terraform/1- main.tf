module "vpc" {
  source                = "./modules/vpc"
  vpc_name              = var.cluster_name
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
  availability_zones    = var.availability_zones
}


module "eks" {
  source                = "./modules/eks"
  cluster_name          = var.cluster_name
  subnet_ids            = module.vpc.private_subnets_ids
  node_desired_capacity = var.node_desired_capacity
  region                = var.region
}


module "ebs" {
  source            = "./modules/ebs"
  availability_zone = "us-west-2a"
  size              = 1
  volume_type       = "gp3"
  name              = "db-volume"
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
module "monitoring" {
  source = "./modules/monitoring"
  # cluster_endpoint              = module.eks.cluster_endpoint
  # cluster_certificate_authority = module.eks.cluster_certificate_authority
  cluster_name = module.eks.cluster_name
  depends_on   = [module.eks]


}