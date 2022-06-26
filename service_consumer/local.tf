locals {
  name            = "service_consumer"
  tags            = {
    Owner         = "user"
    Environment   = "staging"
    Name          = "consumer"
  }
  environment     = "staging"
  product_domain  = "abc"
  service_name    = "nginx"
}