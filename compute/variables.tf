############################
# General Variables
############################

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "3tier-app"
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
  default     = "dev"
}

############################
# EC2 / Launch Template
############################

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-08d7aabbb50c2c24e" # Amazon Linux 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "user_data_file" {
  description = "Path to user data script"
  type        = string
  default     = "compute/user-data.sh"
}

############################
# Auto Scaling Group
############################

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 3
}

############################
# Networking Inputs
############################

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "private_app_subnets" {
  description = "List of private app subnet IDs for ASG"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

############################
# Ports
############################

variable "app_port" {
  description = "Application port for EC2 and ALB"
  type        = number
  default     = 80
}
