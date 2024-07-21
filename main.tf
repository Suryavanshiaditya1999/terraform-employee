terraform {
  backend "s3" {
    bucket = "ot-micro-services1"
    key    = "terraformp9/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_vpc" "ot_microservices_dev" {
  cidr_block       = "10.0.0.0/25"
  instance_tenancy = "default"
  tags = {
    Name = "ot-micro-vpc"
  }
}
