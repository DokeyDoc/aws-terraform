terraform {
  backend "s3" {
    bucket = "terraform-bucket-roivioli"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}

variable "ec2_type" {
  description = "Le type d'instance qu'on souhaite"
  type        = string
  default     = "t4g.nano"
}

variable "ec2_archi" {
  description = "Architecture to use"
  type = string
  default = "arm64"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
  default     = "vpc-0e70c096286612288"  
}

variable "my_ip" {
  description = "Mon adresse IP publique"
  type        = string
}

variable "admin_ips" {
  description = "Liste des adresses IP des administrateurs"
  type        = list(string)
}

data "aws_ami" "auto_ami" {
  # executable_users = ["self"]
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = [var.ec2_archi]
  }
  
}

locals {
  subnet_list = toset(["subnet-095f6c4c32c0be793", "subnet-002bb2d2b9d5cc9f7"])
}

resource "aws_instance" "terraform_test-roivioli" {
  for_each = local.subnet_list
  ami           = "ami-0a7a4e87939439934"
  vpc_security_group_ids = [aws_security_group.admin_ssh.id]
  instance_type = var.ec2_type
  subnet_id = each.value
  key_name      = "vockey"
  tags = {
    Name = "terraform-test-roivioli"
  }
}

resource "aws_instance" "terraform_test" {
  count = 5
  ami           = "ami-0a7a4e87939439934"
  instance_type = var.ec2_type
  key_name      = "vockey"
  tags = {
    Name = "terraform-test${count.index}"
  }
}

resource "aws_s3_bucket" "terraform_s3" {
  bucket = "terraform-test-bucket-roivioli"

  tags = {
    Name        = "terraform-s3"
    Environment = "dev"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}


resource "aws_security_group" "admin_ssh" {

  name = "admin-ssh"

  # dynamic "ingress" {
  #   for_each = var.admin_ips
  #   content {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "tcp"
  #     cidr_blocks = [ingress.value]
  #   }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = [var.my_ip]

  }

  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "admin-ssh"
  }
}

output "public_ip" {
  value = aws_instance.terraform_test[*].public_ip
}

output "private_ip" {
  value = aws_instance.terraform_test[*].private_ip
}

output "ami_id" {
  value = data.aws_ami.auto_ami.id
}

output "ami_name" {
  value = data.aws_ami.auto_ami.name
}
