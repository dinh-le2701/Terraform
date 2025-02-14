terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }
}

resource "aws_s3_bucket" "aws_dev" {
    bucket = "terraform-bucket-my-shop"
}

resource "aws_s3_bucket_versioning" "version" {
    bucket = aws_s3_bucket.aws_dev.id
    versioning_configuration {
        status = "Enabled"
    }
}