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


resource "aws_instance" "terraform_test" {
  ami           = "ami-0a7a4e87939439934"
  instance_type = var.ec2_type
  key_name      = "vockey"
  tags = {
    Name = "terraform-test"
  }
}

resource "aws_s3_bucket" "terraform_s3" {
  bucket = "terraform-test-bucket-roivioli"

  tags = {
    Name        = "terraform-s3"
    Environment = "dev"
  }
}

output "public_ip" {
  value = aws_instance.terraform_test.public_ip
}

output "private_ip" {
  value = aws_instance.terraform_test.private_ip
}

output "ami_id" {
  value = data.aws_ami.auto_ami.id
}
