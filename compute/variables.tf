variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "desired_capacity_app1" {
  description = "ASG desired capacity for app1"
  type        = number
  default     = 2
}

variable "min_size_app1" {
  description = "ASG min size for app1"
  type        = number
  default     = 1
}

variable "max_size_app1" {
  description = "ASG max size for app1"
  type        = number
  default     = 3
}

variable "desired_capacity_app2" {
  description = "ASG desired capacity for app2"
  type        = number
  default     = 2
}

variable "min_size_app2" {
  description = "ASG min size for app2"
  type        = number
  default     = 1
}

variable "max_size_app2" {
  description = "ASG max size for app2"
  type        = number
  default     = 3
}
