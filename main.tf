provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "gyanesh_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "gyanesh-vpc"
  }
}

# Subnet
resource "aws_subnet" "gyanesh_subnet" {
  vpc_id                  = aws_vpc.gyanesh_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "gyanesh-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gyanesh_igw" {
  vpc_id = aws_vpc.gyanesh_vpc.id
  tags = {
    Name = "gyanesh-igw"
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
    Name = "gyanesh-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "gyanesh_rta" {
  subnet_id      = aws_subnet.gyanesh_subnet.id
  route_table_id = aws_route_table.gyanesh_rt.id
}

# Security Group
resource "aws_security_group" "gyanesh_sg" {
  name        = "gyanesh-sg"
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
    Name = "gyanesh-sg"
  }
}

# Elastic IP
resource "aws_eip" "gyanesh_eip" {
  instance = aws_instance.gyanesh_instance.id
  vpc      = true
 "
  }
}

# EC2 Instance
resource "aws_instance" "gyanesh_instance" {
  ami                         = "ami-02b8269d5e85954ef"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.gyanesh_subnet.id
  vpc_security_group_ids      = [aws_security_group.gyanesh_sg.id]
  associate_public_ip_address = true
  key_name                    = "TerraAss"

  tags = {
    Name = "gyanesh-ec2-instance"
  }
}

# S3 Bucket
resource "random_id" "rand" {
  byte_length = 4
}

aws_s3_bucket" "gyanesh_bucket" {
  bucket = "gyanesh-terraform-bucket-${random_id.rand.hex}"
  tags = {
    Name        = "gyanesh-terraform-bucket"
    Environment = "Dev"
  }
}

# Outputs
output "ec2_public_ip" {
  value = aws_instance.gyanesh_instance.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.gyanesh_bucket.bucket
}

output "elastic_ip" {
  value = aws_eip.gyanesh_eip.public_ip
}
