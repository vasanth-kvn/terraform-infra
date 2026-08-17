resource "aws_vpc" "project-vpc" {
  cidr_block = var.cidr

  tags = {
    Name = "var.vpc-name"
  }
}  