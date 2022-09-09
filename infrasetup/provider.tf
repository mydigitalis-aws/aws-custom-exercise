/*terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
*/
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  version = "~>4.0"
}


/*
provider "aws" {
    region = "${var.AWS_REGION}"
    backend "s3" {
    bucket ="digitalis-aws-exercise"
    key = "digitalisexercise.tfstate"
    region ="us-east-1"
  }
}
*/

