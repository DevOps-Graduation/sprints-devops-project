resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "${var.vpc_name}-public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.vpc_name}" = "owned"
    "kubernetes.io/role/elb"                = "1"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                    = "${var.vpc_name}-private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.vpc_name}" = "owned"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}