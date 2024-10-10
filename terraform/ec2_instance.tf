# ec2_instance.tf

# Specify the AWS provider and region
provider "aws" {
  region = var.aws_region
}

# Data source to get the default VPC and subnet
data "aws_vpc" "default" {
  default = true
}

# IAM Role for EC2 to use SSM and access S3
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach the AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the S3 access policy to the role (defined in s3_bucket.tf)
resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Create an instance profile to attach to the EC2 instance
resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "ec2_ssm_instance_profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# Create a security group that allows HTTP access (port 4000)
resource "aws_security_group" "instance_sg" {
  name        = "elixir_app_sg"
  description = "Allow HTTP access to the Phoenix application"

  ingress {
    description = "HTTP for Phoenix App"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to specific IPs for enhanced security
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provision the EC2 instance
resource "aws_instance" "elixir_app" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_instance_profile.name

  tags = {
    Name = "ElixirAppServer"
  }

  # User data script to install Nix and perform initial setup
  user_data = <<-EOF
              #!/bin/bash
              # Update and install dependencies
              sudo yum update -y
              sudo yum install -y curl

              # Install Nix
              sh <(curl -L https://nixos.org/nix/install) --daemon

              # Source Nix profile
              . /etc/profile.d/nix.sh

              # Enable Nix Flakes
              mkdir -p /home/ec2-user/.config/nix
              echo "experimental-features = nix-command flakes" >> /home/ec2-user/.config/nix/nix.conf
              chown -R ec2-user:ec2-user /home/ec2-user/.config

              # Install AWS CLI (if not already installed)
              sudo yum install -y aws-cli

              # Ensure SSM Agent is running (should be by default on Amazon Linux 2)
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              EOF
}

# Outputs
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.elixir_app.public_ip
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.elixir_app.id
}