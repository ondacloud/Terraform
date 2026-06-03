output "alb_target_group_arns" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn }
}

output "alb_target_group_arn_suffixs" {
  value = { for tg_name, tg in aws_lb_target_group.this : tg_name => tg.arn_suffix }
}