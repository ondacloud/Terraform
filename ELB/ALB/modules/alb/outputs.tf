output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns" {
  value = aws_lb.this.dns_name
}

output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "alb_default_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "alb_target_group_arns" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn }
}

output "alb_target_group_arn_suffixs" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn_suffix }
}