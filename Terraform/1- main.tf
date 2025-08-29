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
}

module "ebs" {
  source            = "./modules/ebs"
  availability_zone = "us-west-1a"
  size              = 1
  volume_type       = "gp3"
  name              = "db-volume"
}
