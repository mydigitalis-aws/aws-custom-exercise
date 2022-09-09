#terraform{
/* required_version = ">=0.12.24"

  backend "s3" {
    bucket ="digitalis-aws-exercise"
    key = "digitalisexercise.tfstate"
    region ="us-east-1"
  }
  
  provider "aws" {
  version = "~>3.0"
 #region  = "east-us-1"
 region = "${var.AWS_REGION}"
}

}*/

 terraform {
   backend "s3" {
     bucket = "digitalis-exercise-terraform-state"
     #key    = "digitalis-infrastructure"
     key    = "global/s3/digitalis-infrastructure.tfstate"
     region = "${var.AWS_REGION}"
   }
 }

resource "aws_s3_bucket" "terraform_state" {
  bucket = "digitalis-exercise-terraform-state"

  versioning {
    enabled = true
  }
  
server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}