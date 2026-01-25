output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_alb.dns_name
}

output "app_sg_id" {
  description = "Security group ID for the application EC2/ASG"
  value       = aws_security_group.app_sg.id
}