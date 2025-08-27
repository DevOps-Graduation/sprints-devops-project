module "vpc" {
  source = "./vpc.tf"
}

module "security" {
  source = "./security.tf"
}

module "eks" {
  source = "./eks.tf"
}
