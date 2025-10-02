output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "app_alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "alb_default_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "alb_target_group_arns" {
  value = [for tg in aws_lb_target_group.this : tg.arn]
}