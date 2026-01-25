variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "aws-3tier"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
