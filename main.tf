resource "aws_vpc" "vpc_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}-${random_id.vpc_suffix.hex}"
  }
}

resource "random_id" "vpc_suffix" {
  byte_length = 4
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_network.id
  tags = {
    Name = "${var.vpc_name}-igw-${random_id.vpc_suffix.hex}"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-1-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-2-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.vpc_network.id
  cidr_block              = var.public_subnet_3_cidr
  availability_zone       = var.availability_zone_3
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-3-${random_id.vpc_suffix.hex}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zone_1
  tags = {
    Name = "${var.vpc_name}-private-1-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zone_2
  tags = {
    Name = "${var.vpc_name}-private-2-${random_id.vpc_suffix.hex}"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.vpc_network.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.availability_zone_3
  tags = {
    Name = "${var.vpc_name}-private-3-${random_id.vpc_suffix.hex}"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_network.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt-${random_id.vpc_suffix.hex}"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_network.id
  tags = {
    Name = "${var.vpc_name}-private-rt-${random_id.vpc_suffix.hex}"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_rt.id
}

# Application Security Group
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.vpc_network.id
  name   = "${var.vpc_name}-app-sg"

  ingress {
    from_port   = var.ingress_ssh_port
    to_port     = var.ingress_ssh_port
    protocol    = var.protocol
    cidr_blocks = [var.cidr_sg]
  }

  ingress {
    from_port   = var.ingress_eighty_port
    to_port     = var.ingress_eighty_port
    protocol    = var.protocol
    cidr_blocks = [var.cidr_sg]
  }

  ingress {
    from_port   = var.ingress_443_port
    to_port     = var.ingress_443_port
    protocol    = var.protocol
    cidr_blocks = [var.cidr_sg]
  }

  ingress {
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = var.protocol
    cidr_blocks = [var.cidr_sg]
  }

  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_protocol
    cidr_blocks = [var.cidr_sg]
  }

  tags = {
    Name = "${var.vpc_name}-app-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_app" {
  ami                    = var.custom_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = var.key_name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  monitoring              = false
  disable_api_termination = false

  tags = {
    Name = "${var.vpc_name}-ec2"
  }
}
