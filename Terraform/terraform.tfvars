region                = "us-west-2"
vpc_cidr              = "10.0.0.0/16"
cluster_name          = "voting-app-345"
node_desired_capacity = 2
public_subnets_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones    = ["us-west-2a", "us-west-2b"]
