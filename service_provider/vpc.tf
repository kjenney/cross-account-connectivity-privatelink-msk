module "vpc" {
  source                = "terraform-aws-modules/vpc/aws"
  version               = "3.14.2"

  name                  = "consumer"
  cidr                  = "10.11.0.0/16"
  enable_dns_hostnames  = true

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ]
  private_subnets       = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
  public_subnets        = ["10.11.11.0/24"]

  single_nat_gateway    = true
  enable_nat_gateway    = true

  tags = local.tags
}

module "vpc_endpoints" {
  source                = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version               = "3.14.2"

  vpc_id                = module.vpc.vpc_id
  security_group_ids    = [data.aws_security_group.default.id]

  endpoints = {
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_tls.id]
    },
    ssmmessages = {
      service             = "ssmmessages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ec2messages = {
      service             = "ec2messages"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
  }

  tags = merge(local.tags, {
    Project  = "Secret"
    Endpoint = "true"
  })
}

