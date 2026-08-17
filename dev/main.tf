terraform {
  backend "s3" {
    bucket = "5terraform-1234"
    key = "dev/dev.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region

}
module "vpc" {
  source   = "../modules/project-vpc"
  cidr     = "10.0.0.0/16"
  vpc-name = var.vpc-name
}
module "public_subnet" {
  source            = "../modules/project_subnet"
  vpc_id            = module.vpc.vpc_id
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone

}
module "internet_gateway" {
  source = "../modules/internet-gateway"
  vpc_id = module.vpc.vpc_id
}
module "route_table" {
  source    = "../modules/route-table"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.public_subnet.subnet_id
  igw   = module.internet_gateway.igw_id
}
module "security_group" {
  source = "../modules/security-group"
  vpc_id = module.vpc.vpc_id
}
module "instance" {
  source = "../modules/ec2"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.public_subnet.subnet_id
  security_group_id = module.security_group.security_group_id
}