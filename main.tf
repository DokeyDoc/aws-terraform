provider "aws" {
  region = "us-east-1"
}

variable "ec2_type" {
  description = "Le type d'instance qu'on souhaite"
  type        = string
  default     = "t4g.nano"
}

resource "aws_instance" "terraform_test" {
  ami           = "ami-0e532fbed6ef00604"
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