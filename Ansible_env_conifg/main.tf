provider "aws" {
  region = var.aws_region
}

# Generate SSH key pair locally
resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload public key to AWS
resource "aws_key_pair" "lab_keypair" {
  key_name   = "ansible-lab-key"
  public_key = tls_private_key.lab_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.lab_key.private_key_pem
  filename        = "${path.module}/ansible-lab-key.pem"
  file_permission = "0600"
}

# Networking
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "lab_gw" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_route_table" "lab_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_gw.id
  }
}

resource "aws_route_table_association" "lab_rta" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_rt.id
}

# Security Group
resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Managed Nodes (Amazon Linux 2)
resource "aws_instance" "managed_nodes" {
  count                  = 2
  ami                    = var.amazon_linux2_ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = aws_key_pair.lab_keypair.key_name

  user_data = templatefile("${path.module}/cloudinit-managed.tpl", {
    hostname            = "managed-node-${count.index + 1}"
    control_node_pubkey = tls_private_key.lab_key.public_key_openssh
  })

  tags = {
    Name = "ansible-managed-${count.index + 1}"
  }
}

# Control Node (RHEL 9)
resource "aws_instance" "control_node" {
  ami                    = var.rhel9_ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.lab_subnet.id
  vpc_security_group_ids = [aws_security_group.lab_sg.id]
  key_name               = aws_key_pair.lab_keypair.key_name

  user_data = templatefile("${path.module}/cloudinit-control.tpl", {
    rhsm_username     = var.rhsm_username
    rhsm_password     = var.rhsm_password
    managed_nodes_ips = aws_instance.managed_nodes[*].private_ip
  })

  tags = {
    Name = "ansible-control-node"
  }
}

# Outputs
output "private_key_path" {
  value     = local_file.private_key.filename
  sensitive = true
}

output "control_node_ip" {
  value = aws_instance.control_node.public_ip
}

output "managed_nodes_ips" {
  value = aws_instance.managed_nodes[*].private_ip
}

output "managed_nodes_public_ips" {
  value = aws_instance.managed_nodes[*].public_ip
}