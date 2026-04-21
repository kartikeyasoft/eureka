terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get the latest Eureka AMI
data "aws_ami" "eureka" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["myapp-eureka-v*"]
  }
}

# Try to fetch existing security group by name
data "aws_security_group" "eureka" {
  filter {
    name   = "group-name"
    values = ["eureka-sg-${var.environment}"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Create security group only if it doesn't exist
resource "aws_security_group" "eureka" {
  count = length(data.aws_security_group.eureka.*.id) == 0 ? 1 : 0
  
  name        = "eureka-sg-${var.environment}"
  description = "Security group for Eureka service registry"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8761
    to_port     = 8761
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Eureka dashboard"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eureka-sg-${var.environment}"
    Environment = var.environment
    Service     = "eureka"
  }
}

# Get the security group ID (either existing or newly created)
locals {
  security_group_id = length(data.aws_security_group.eureka.*.id) > 0 ? data.aws_security_group.eureka.id : aws_security_group.eureka[0].id
}

# EC2 Instance
resource "aws_instance" "eureka" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.eureka.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [local.security_group_id]
  key_name               = var.key_name

  tags = {
    Name        = "eureka-${var.environment}"
    Environment = var.environment
    Service     = "eureka"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP (Optional)
resource "aws_eip" "eureka" {
  count    = var.assign_eip ? 1 : 0
  instance = aws_instance.eureka.id
  domain   = "vpc"

  tags = {
    Name        = "eureka-eip-${var.environment}"
    Environment = var.environment
  }
}
