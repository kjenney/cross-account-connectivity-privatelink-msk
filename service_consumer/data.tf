data "aws_availability_zones" "available" {}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "terraform_remote_state" "service_provider" {
  backend     = "s3"
  config      = {
    bucket    = "kenjenney.com.privatelink"
    role_arn  = "arn:aws:iam::313697402033:role/OrganizationAccountAccessRole"
    key       = "terraform.state"
  }
}

data "aws_caller_identity" "current" {}

data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-2.0.2022*"]
  }
}