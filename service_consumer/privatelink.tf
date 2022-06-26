module "service-provider-privatelink" {
  providers = {
    aws                 = aws.service_provider_assume_role
  }
  source                = "github.com/traveloka/terraform-aws-privatelink-provider?ref=master"
  
  nlb_arns              = [data.terraform_remote_state.service_provider.outputs.nlb_arn]
  allowed_principals    = [data.aws_caller_identity.current.arn]
  acceptance_required   = false

  service_name          = local.service_name
  product_domain        = local.product_domain
  environment           = local.environment
  description           = format("VPC Endpoint Service for service %s", local.service_name)
}

module "service-consumer-privatelink" {
  source                  = "github.com/traveloka/terraform-aws-privatelink-consumer?ref=master"

  vpc_id                  = module.vpc.vpc_id
  available_subnet_ids    = module.vpc.private_subnets
  security_group_ids      = [aws_security_group.access_nginx_service.id]
  service_provider_name   = module.service-provider-privatelink.service_provider_name
  #private_dns_enabled     = true

  product_domain          = local.product_domain
  service_name            = local.service_name
  environment             = local.environment
}