### Create an NLB for each of the MSK brokers
### Along with Target Groups and Listeners

data "aws_msk_broker_nodes" "primary" {
  cluster_arn = aws_msk_cluster.primary.arn
}

resource "aws_lb" "msk" {
  count              = local.number_of_broker_nodes
  name               = "${local.name}${count.index}"
  load_balancer_type = "network"
  internal           = true

  subnet_mapping {
    subnet_id = local.msk_subnets[count.index]
  }
}

resource "aws_lb_target_group" "nlb_target_groups" {
  count       = local.number_of_broker_nodes
  name        = "broker${count.index}"
  port        = 9098
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "tgr_attachment" {
  for_each = {
    for i, k in aws_lb_target_group.nlb_target_groups :
    i => {
      target_group = aws_lb_target_group.nlb_target_groups[i]
      instance_ip  = data.aws_msk_broker_nodes.primary.node_info_list[i].client_vpc_ip_address
    }
  }
  target_group_arn = each.value.target_group.arn
  target_id        = each.value.instance_ip
  port             = 9098
}

resource "aws_lb_listener" "nlb_listerner" {
  for_each = {
    for i, k in aws_lb_target_group.nlb_target_groups :
    i => {
      target_group = aws_lb_target_group.nlb_target_groups[i]
      lb           = aws_lb.msk[i]
    }
  }
  load_balancer_arn = each.value.lb.arn
  port              = 9098
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.target_group.arn
  }
}