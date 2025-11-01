# AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Random ID for unique S3 bucket name
resource "random_id" "rand" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "terraformgb_bucket" {
  bucket = "terraformgb-s3-bucket-${random_id.rand.hex}"

  tags = {
    Name        = "terraformgb-s3-bucket"
    Environment = "Dev"
  }
}

# VPC
resource "aws_vpc" "gyanesh_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform_VPC"
  }
}

# Subnet
resource "aws_subnet" "gyanesh_subnet" {
  vpc_id                  = aws_vpc.gyanesh_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terra_subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gyanesh_igw" {
  vpc_id = aws_vpc.gyanesh_vpc.id

  tags = {
    Name = "Terraform_IGW"
  }
}

# Route Table
resource "aws_route_table" "gyanesh_rt" {
  vpc_id = aws_vpc.gyanesh_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gyanesh_igw.id
  }

  tags = {
    Name = "Terraform_RouteTable"
  }
}

# Route Table Association
resource "aws_route_table_association" "gyanesh_rta" {
  subnet_id      = aws_subnet.gyanesh_subnet.id
  route_table_id = aws_route_table.gyanesh_rt.id
}

# Security Group
resource "aws_security_group" "gyanesh_sg" {
  name        = "terraform-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.gyanesh_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform_SecurityGroup"
  }
}

# EC2 Instance
resource "aws_instance" "terraform_ins" {
  ami                         = "ami-0dee22c13ea7a9a67" # Ubuntu 24.04 LTS
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.gyanesh_subnet.id
  vpc_security_group_ids      = [aws_security_group.gyanesh_sg.id]
  associate_public_ip_address = true
  key_name                    = "terraform-keypair"

  tags = {
    Name = "Terraform_ins"
  }
}
