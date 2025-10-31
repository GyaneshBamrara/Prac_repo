provider "aws" {
  region = "ap-south-1"
}

# VPC
resource "aws_vpc" "prac_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Prac_VPC"
  }
}

# Subnet
resource "aws_subnet" "terra_subnet" {
  vpc_id                  = aws_vpc.prac_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Terra_subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.prac_vpc.id
  tags = {
    Name = "Terra_IGW"
  }
}

# Route Table
resource "aws_route_table" "terra_route_table" {
  vpc_id = aws_vpc.prac_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }

  tags = {
    Name = "Terra_Route_Table"
  }
}

# Route Table Association
resource "aws_route_table_association" "terra_rta" {
  subnet_id      = aws_subnet.terra_subnet.id
  route_table_id = aws_route_table.terra_route_table.id
}

# Security Group
resource "aws_security_group" "terra_sg" {
  name        = "Terra_SG"
  description = "Allow SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.prac_vpc.id

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

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "Terra_SG"
  }
}

# S3 Bucket
resource bucket = "bg-s3-prac"

  tags = {
    Name = "bg-s3-prac"
  }
}

resource "aws_s3_bucket_versioning" "bg_s3_prac_versioning" {
  bucket = aws_s3_bucket.bg_s3_prac.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bg_s3_prac_block" {
  bucket = aws_s3_bucket.bg_s3_prac.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# EC2 Instance
resource "aws_instance" "prac_ins" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.terra_subnet.id
  key_name      = "KeyTer.pem"
  security_groups = [aws_security_group.terra_sg.name]

  tags = {
    Name = "Prac_ins"
  }
}
