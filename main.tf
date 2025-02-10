provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraform_test" {
  ami           = "ami-085ad6ae776d8f09c"
  instance_type = "t2.nano"
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

