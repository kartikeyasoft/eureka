terraform {
  required_version = ">= 1.0"
  backend "local" {   # Change to s3 for production
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "golden_eureka" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["myapp-eureka-v*"]
  }
}

resource "aws_instance" "eureka" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.golden_eureka.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "eureka-prod-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  }
}

output "eureka_public_ip" {
  value = aws_instance.eureka.public_ip
}

output "eureka_private_ip" {
  value = aws_instance.eureka.private_ip
}
