resource "aws_security_group" "primary" {
  name        = "${local.name}_msk"
  description = "Primary security group for ${local.name} MSK Cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "MSK inbound traffic from anywhere, private IAM port"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_cloudwatch_log_group" "primary" {
  name = "${local.name}_msk_logs"
}

locals {
  kafka_version                   = "2.8.1"
  broker_server_properties_joined = join("\n", [for k, v in local.broker_server_properties : format("%s = %s", k, v)])
  msk_subnets                     = slice(module.vpc.private_subnets, 0, 3)
  number_of_broker_nodes          = length(local.msk_subnets)
  broker_server_properties = {
    "auto.create.topics.enable" = "true"
    "delete.topic.enable"       = "true"
  }
}

resource "aws_msk_cluster" "primary" {
  cluster_name           = local.name
  kafka_version          = local.kafka_version
  number_of_broker_nodes = local.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = "kafka.m5.xlarge"
    ebs_volume_size = 100
    client_subnets  = local.msk_subnets
    security_groups = [aws_security_group.primary.id]
  }

  client_authentication {
    sasl {
      iam = true
    }
    unauthenticated = false
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.primary.name
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.primary.arn
    revision = aws_msk_configuration.primary.latest_revision
  }

  tags = {
    Name = "${local.name}_msk"
  }
}

resource "aws_msk_configuration" "primary" {
  kafka_versions    = [local.kafka_version]
  name              = local.name
  server_properties = local.broker_server_properties_joined
}

resource "aws_secretsmanager_secret" "primary" {
  name = "${local.name}_msk_broker_info"

  recovery_window_in_days = 0

  tags = {
    Name = "${local.name}_msk"
  }
}

resource "aws_secretsmanager_secret_version" "primary" {
  secret_id = aws_secretsmanager_secret.primary.id
  secret_string = jsonencode({
    boostrap_brokers = aws_msk_cluster.primary.bootstrap_brokers_sasl_iam
  })
}
