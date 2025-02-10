provider "aws" {
  region = "us-east-1"
}

resource "local_file" "foo" {
  content         = "Hello DevOps !"
  filename        = "${path.module}/devops.txt"
  file_permission = "0644"
}