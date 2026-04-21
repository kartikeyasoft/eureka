variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "ami_id" {
  description = "Eureka AMI ID (leave empty to use latest)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
  default     = "subnet-0aa31e769c8f4d73e"  # ← Your actual subnet ID
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-0cb7deb47a6bfa727"  # ← Your actual VPC ID
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "ksansible"  # ← Your actual key pair name
}

variable "assign_eip" {
  description = "Assign Elastic IP to instance"
  type        = bool
  default     = false
}
