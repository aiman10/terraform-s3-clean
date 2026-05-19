terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "tf-remote-backend-ehb-863745572691"
    key          = "terraform-s3-clean/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 bucket created by Terraform"
  type        = string
  default     = "mlops-course-ehb-datastore-dev-863745572691"
}

resource "aws_s3_bucket" "datastore" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
    ManagedBy   = "terraform"
    Course      = "mlops"
  }
}

resource "aws_s3_bucket_public_access_block" "datastore" {
  bucket = aws_s3_bucket.datastore.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "datastore" {
  bucket = aws_s3_bucket.datastore.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "datastore" {
  bucket = aws_s3_bucket.datastore.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.datastore.bucket
}

output "bucket_region" {
  value = var.aws_region
}

output "backend_state_bucket" {
  value = "tf-remote-backend-ehb-863745572691"
}