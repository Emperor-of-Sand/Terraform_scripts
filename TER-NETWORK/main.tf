provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.az

  tags = {
    Name = "public-subnet"
  }
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.az
  map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
      Name = "internet-gateway" 
  }
}

# Create NAT Gateway
resource "aws_eip" "nat_gw" {
    domain = "vpc"
}

resource "aws_nat_gateway" "main_nat_gw" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-gateway"
  }
}

# Create Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
# Create Route Table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id  

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_nat_gw.id
  }
    tags = {
        Name = "private-route-table"
    }
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# Create Security Group for public subnet
resource "aws_security_group" "public_sg" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    # ingress 443
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
        Name = "public-security-group"
    }
}

# Create Security Group for private Access
resource "aws_security_group" "private_sg" {
    vpc_id = aws_vpc.main_vpc.id

    ingress {
        # port 22
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "private-security-group"
    }
}