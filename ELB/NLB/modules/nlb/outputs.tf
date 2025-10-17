output "nlb_arn" {
  value = aws_lb.this.arn
}

output "nlb_dns" {
  value = aws_lb.this.dns_name
}

output "nlb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}

output "nlb_default_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "nlb_target_group_arns" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn }
}

output "nlb_target_group_arn_suffixs" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn_suffix }
}