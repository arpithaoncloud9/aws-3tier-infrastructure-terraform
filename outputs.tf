output "vpc_id" {
  description = "VPC ID from VPC module"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnets from VPC module"
  value       = module.vpc.public_subnets
}

output "private_app_subnets" {
  description = "Private app subnets from VPC module"
  value       = module.vpc.private_app_subnets
}

output "alb_dns_name" {
  description = "ALB DNS name from compute module"
  value       = module.compute.alb_dns_name
}
