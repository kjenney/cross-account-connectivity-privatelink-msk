output "msk_nlb_arns" {
  value = aws_lb.msk.*.arn
}