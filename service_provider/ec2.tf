resource "aws_security_group" "vpc_tls" {
  name_prefix = "${local.name}-vpc_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = local.tags
}

resource "aws_security_group" "access_nginx_service" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.access_nginx_service.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.access_nginx_service.id
}

locals {
  user_data = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  sudo amazon-linux-extras enable epel
  sudo yum install -y epel-release
  sudo yum install -y nginx
  sudo systemctl start nginx.service
  sudo yum install -y nc
  EOT
}

module "ec2_instance" {
  source                  = "terraform-aws-modules/ec2-instance/aws"
  version                 = "~> 3.0"

  name                    = "${local.name}-nginx"

  ami                     = data.aws_ami.default.id
  instance_type           = "t2.micro"
  iam_instance_profile    = aws_iam_instance_profile.ssm.id
  monitoring              = true
  vpc_security_group_ids  = [aws_security_group.access_nginx_service.id,module.vpc.default_security_group_id]
  subnet_id               = element(module.vpc.private_subnets, 0)
  user_data_base64        = base64encode(local.user_data)

  tags                    = local.tags
}

module "ec2_instance2" {
  source                  = "terraform-aws-modules/ec2-instance/aws"
  version                 = "~> 3.0"

  name                    = "${local.name}-test"

  ami                     = data.aws_ami.default.id
  instance_type           = "t2.micro"
  iam_instance_profile    = aws_iam_instance_profile.ssm.id
  monitoring              = true
  vpc_security_group_ids  = [aws_security_group.access_nginx_service.id,module.vpc.default_security_group_id]
  subnet_id               = element(module.vpc.private_subnets, 0)

  tags                    = local.tags
}
