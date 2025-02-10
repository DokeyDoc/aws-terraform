provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "terraform-test" {
  ami           = "ami-085ad6ae776d8f09c"
  instance_type = "t2.nano"
  key_name      = "vockey"
  tags = {
    Name = "terraform-test"
  }
}