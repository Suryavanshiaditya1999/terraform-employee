terraform {
  backend "s3" {
    bucket = "ot-micro-services11"
    key    = "terraformp9/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_subnet" "public_subnet_1" {
 vpc_id            = aws_vpc.ot_microservices_dev.id
 cidr_block        = "10.0.0.0/28"
 availability_zone = "us-east-2a"
 map_public_ip_on_launch = true
 tags = {
   Name = "Public Subnet 1"
 }
}
