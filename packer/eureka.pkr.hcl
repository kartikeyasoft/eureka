variable "service_name" {
  type = string
}
variable "service_version" {
  type = string
}
variable "base_image" {
  type    = string
  default = "ubuntu-focal-22.04"
}
variable "nexus_url" {
  type    = string
  default = "http://your-nexus:8081/repository/maven-releases"
}

source "amazon-ebs" "eureka" {
  ami_name        = "myapp-${var.service_name}-v${var.service_version}"
  instance_type   = "t3.micro"
  region          = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "${var.base_image}-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.eureka"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbook-eureka.yml"
    ansible_env_vars = [
      "SERVICE_NAME=${var.service_name}",
      "SERVICE_VERSION=${var.service_version}",
      "NEXUS_URL=${var.nexus_url}"
    ]
  }
}
