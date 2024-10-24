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

# Database Security Group
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.vpc_network.id
  name   = "${var.vpc_name}-db-sg"

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

# EC2 Instance with User Data (moved above RDS Instance)
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

  user_data = <<-EOF
                #!/bin/bash
                env_file="/opt/webapp/.env"

                DB_HOSTNAME=$(echo "${aws_db_instance.db_instance.endpoint}" | cut -d':' -f1)

                echo "DB_HOST=$DB_HOSTNAME" >> "$env_file"
                echo "DB_DATABASE=csye6225" >> "$env_file"
                echo "DB_USERNAME=csye6225" >> "$env_file"
                echo "DB_PASSWORD=${var.db_password}" >> "$env_file"
                echo "SERVER_PORT=${var.application_port}" >> "$env_file"
                # Restart the application service
                sudo systemctl restart csye6225.service
                EOF

  tags = {
    Name = "${var.vpc_name}-ec2"
  }
}

# RDS Parameter Group for PostgreSQL 13
resource "aws_db_parameter_group" "db_param_group" {
  name        = "${var.vpc_name}-rds-params"
  family      = "postgres13" # Set to postgres13
  description = "Custom parameter group for ${var.db_engine}"

  tags = {
    Name = "${var.vpc_name}-db-param-group"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.vpc_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "${var.vpc_name}-db-subnet-group"
  }
}

# RDS Instance for PostgreSQL 13
resource "aws_db_instance" "db_instance" {
  identifier             = "csye6225"
  engine                 = var.db_engine
  engine_version         = var.engine_version      # Use PostgreSQL version 13.7
  instance_class         = var.instance_class      # Compatible instance class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az               = false
  publicly_accessible    = false
  username               = var.username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.db_param_group.name
  db_name                = var.db_name
  port                   = var.db_port
  skip_final_snapshot    = true

  tags = {
    Name = "${var.vpc_name}-rds-instance"
  }
}
