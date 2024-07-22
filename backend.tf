terraform {
  backend "s3" {
    bucket = "ot-micro-services1"
    key    = "terraformp9/terraform.tfstate"
    region = "us-east-2"
  }
}
