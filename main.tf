provider "aws" {
  region = "us-east-1"  # Change this as per your requirement
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Create a Subnet
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Create a Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_table.id
}

# Create a Security Group
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (not recommended for production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Instance
resource "aws_instance" "my_instance" {
  ami           = "ami-085ad6ae776d8f09c"  # Change this to a valid AMI for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true  #  Assigns a public IP 

  tags = {
    Name = "Terraform-Instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
