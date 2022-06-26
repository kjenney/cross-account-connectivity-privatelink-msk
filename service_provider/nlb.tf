resource "aws_lb" "link" {
  name               = local.name
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets
}

resource "aws_lb_target_group" "link_http" {
  name     = "linktg"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "link_http" {
  target_group_arn = aws_lb_target_group.link_http.arn
  target_id        = module.ec2_instance.id
  port             = 80
}

resource "aws_lb_listener" "link_http" {
  load_balancer_arn = aws_lb.link.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.link_http.arn
  }
}