# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ec2_ami" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-0c94855ba95c71c99"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store application artifacts"
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy resources in."
  default     = "subnet-ddfde5f3" # us-east-1b subnet ID in my default VPC
}