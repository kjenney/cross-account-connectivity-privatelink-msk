terraform {
  backend "s3" {
    bucket = "kenjenney.com.privatelink"
    key    = "terraform.state"
    region = "us-east-1"
  }
}
