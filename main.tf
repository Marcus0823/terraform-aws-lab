provider "aws" {
  region     = "us-east-1"
}

# -------------------------------
# Create a VPC, Subnet, IGW, and Route Table
# -------------------------------
resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "first-vpc"
  }
}

resource "aws_internet_gateway" "first-igw" {
  vpc_id = aws_vpc.first-vpc.id
  tags = {
    Name = "first-igw"
  }
}

resource "aws_route_table" "first-route-table" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.first-igw.id
  }

  tags = {
    Name = "first-route-table"
  }
}

resource "aws_subnet" "first-subnet" {
  vpc_id            = aws_vpc.first-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "first-subnet"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.first-subnet.id
  route_table_id = aws_route_table.first-route-table.id
}

# -------------------------------
# Security Group for SSH, HTTP, HTTPS
# -------------------------------
resource "aws_security_group" "allow_web_traffic" {
  vpc_id      = aws_vpc.first-vpc.id
  name        = "allow_web_traffic"
  description = "Allow web traffic inbound"

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
    Name = "allow_web_traffic"
  }
}

# -------------------------------
# Network Interface, Elastic IP, and Instance
# -------------------------------
resource "aws_network_interface" "wb-server-nic" {
  subnet_id       = aws_subnet.first-subnet.id
  private_ips     = ["10.0.1.10"]
  security_groups = [aws_security_group.allow_web_traffic.id]
  tags = {
    Name = "wb-server-nic"
  }
}

resource "aws_eip" "wb-server-eip" {
  domain = "vpc"
  network_interface = aws_network_interface.wb-server-nic.id
  associate_with_private_ip = "10.0.1.10"
  depends_on = [aws_internet_gateway.first-igw]
}


resource "aws_instance" "wb-server" {
  ami               = "ami-0360c520857e3138f"
  availability_zone = "us-east-1a"
  instance_type     = "t3.micro"
  key_name          = "main-key"

  network_interface {
    network_interface_id = aws_network_interface.wb-server-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "<h1>Welcome to the Web Server</h1>" | sudo tee /var/www/html/index.html
  EOF

  tags = {
    Name = "wb-server"
  }
}
