#############################################
# Outputs for Day‑2 Compute Module
#############################################

# ALB DNS Name (most important output)
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

# Target Group ARN (useful for debugging or chaining modules)
output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.app_tg.arn
}

# Auto Scaling Group Name
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

# Launch Template ID
output "launch_template_id" {
  description = "ID of the Launch Template used by ASG"
  value       = aws_launch_template.app_lt.id
}
