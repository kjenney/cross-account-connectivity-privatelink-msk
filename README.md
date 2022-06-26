# cross-account-connectivity-privatelink-msk

MSK Brokers connected to a VPC in a different account using Privatelink

## Architecture

2 separate AWS accounts:

1. service_provider: AWS Account that is hosting a service.
2. service_consumer: AWS Account that is accessing the service_provider service.

* 1 VPC per AWS account - separate CIDRs per VPC
* VPC's have SSM enabled for Systems Manager access to login to EC2 instance to test
* 1 EC2 instance in each VPC for testing

## Setup Service Provider

```
cd service_provider
aws-vault exec ken1 -- terraform init
aws-vault exec ken1 -- terraform plan -out .tfplan
aws-vault exec ken1 -- terraform apply .tfplan
```

## Setup Service Consumer

```
cd service_consumer
aws-vault exec me -- terraform init
aws-vault exec me -- terraform plan -out .tfplan
aws-vault exec me -- terraform apply .tfplan
```
