#######################################
# VPC & Networking Infrastructure
#######################################

# VPC Configuration
resource "aws_vpc" "vpc_network" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}-${random_id.vpc_suffix.hex}"
  }
}

# Generate Random ID for Unique Naming
resource "random_id" "vpc_suffix" {
  byte_length = 4
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_network.id
  tags = {
    Name = "${var.vpc_name}-igw-${random_id.vpc_suffix.hex}"
  }
}

#######################################
# Subnet Configuration (Public & Private)
#######################################

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

#######################################
# Route Tables and Associations
#######################################

# Public Route Table and Route for Internet Gateway
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

#######################################
# S3 Bucket Configuration
#######################################

# S3 Bucket with UUID Naming, Lifecycle Policy, and Encryption
resource "random_uuid" "s3_bucket_name" {}

resource "aws_s3_bucket" "private_bucket" {
  bucket        = "${var.bucket_name}-${random_uuid.s3_bucket_name.result}"
  force_destroy = true

  tags = {
    Name = "My Private S3 Bucket"
  }
}

# S3 Bucket Lifecycle Policy for Transition to STANDARD_IA after 30 Days
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id     = "TransitionToIA"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Enable Default Server-Side Encryption for S3 Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "s3_bucket_access_block" {
  bucket                  = aws_s3_bucket.private_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy to Deny Insecure Requests
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.private_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "DenyPublicRead",
        Effect    = "Deny",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.private_bucket.arn}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

#######################################
# Security Groups
#######################################

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

#######################################
# IAM Roles & Policies for EC2 and S3 Access
#######################################

# IAM Role for EC2 instance with CloudWatch Agent and S3 Access
resource "aws_iam_role" "ec2_role" {
  name = "EC2CloudWatchS3AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy Attachment for CloudWatch Agent
resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# S3 Bucket Access Policy Document for EC2 Role
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.private_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.ec2_role.arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["${aws_s3_bucket.private_bucket.arn}"]
  }
}

# EC2 Instance Profile for IAM Role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

#######################################
# EC2 Instance Configuration
#######################################

# EC2 Instance with CloudWatch Agent for Ubuntu
resource "aws_instance" "web_app" {
  ami                    = var.custom_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  monitoring              = false
  disable_api_termination = false

  # User Data Script for App & CloudWatch Agent Setup
  user_data = <<-EOF
    #!/bin/bash
    # Define environment variables
    env_file="/opt/webapp/.env"
    DB_HOSTNAME=$(echo "${aws_db_instance.db_instance.endpoint}" | cut -d':' -f1)

    # Create .env file for the application
    echo "DB_HOST=$DB_HOSTNAME" >> "$env_file"
    echo "DB_DATABASE=csye6225" >> "$env_file"
    echo "DB_USERNAME=csye6225" >> "$env_file"
    echo "DB_PASSWORD=${var.db_password}" >> "$env_file"
    echo "SERVER_PORT=${var.application_port}" >> "$env_file"
    echo "REGION=${var.region}" >> "$env_file"
    echo "AWS_ACCESS_KEY_ID=${var.keyID}" >> "$env_file"
    echo "AWS_SECRET_ACCESS_KEY=${var.key}" >> "$env_file"

    # Restart application service
    sudo systemctl restart csye6225.service

    # Pass Bucket Name to Application
    echo "S3_BUCKET=${aws_s3_bucket.private_bucket.bucket}" >> "$env_file"

    # Download and install CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

    # Fetch the InstanceId for CloudWatch dimension
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

    # Create CloudWatch Agent configuration with InstanceId as a dimension
    cat <<'CONFIG' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    {
      "agent": {
          "metrics_collection_interval": 10,
          "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
      },
      "logs": {
          "logs_collected": {
              "files": {
                  "collect_list": [
                      {
                          "file_path": "/var/log/syslog",
                          "log_group_name": "EC2AppLogs",
                          "log_stream_name": "syslog",
                          "timestamp_format": "%b %d %H:%M:%S"
                      },
                      {
                          "file_path": "/opt/webapp/logs/app.log",
                          "log_group_name": "EC2AppLogs",
                          "log_stream_name": "app_log",
                          "timestamp_format": "%Y-%m-%dT%H:%M:%S.%LZ"
                      }
                  ]
              }
          }
      },
      "metrics": {
        "append_dimensions": {
          "InstanceId": "$INSTANCE_ID"
        },
        "metrics_collected": {
          "statsd": {
            "service_address": ":8125",
            "metrics_collection_interval": 15,
            "metrics_aggregation_interval": 300
          },
          "disk": {
            "resources": ["/"],
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
    CONFIG

    # Start CloudWatch Agent with configuration
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
  EOF

  tags = {
    Name = "${var.vpc_name}-ec2"
  }
}

#######################################
# RDS (PostgreSQL) Configuration
#######################################

# RDS Parameter Group for PostgreSQL
resource "aws_db_parameter_group" "db_param_group" {
  name        = "${var.vpc_name}-rds1-params"
  family      = "postgres13"
  description = "Custom parameter group for ${var.db_engine}"

  tags = {
    Name = "${var.vpc_name}-db-param-group"
  }
}

# RDS DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.vpc_name}-db-subnet1-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "${var.vpc_name}-db-subnet1-group"
  }
}

# RDS Instance for PostgreSQL 13
resource "aws_db_instance" "db_instance" {
  identifier             = "csye6225"
  engine                 = var.db_engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
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

#######################################
# Route53 DNS Configuration
#######################################

# Route 53 A Record for EC2 Instance
resource "aws_route53_record" "a_record" {
  zone_id = var.route53_zone_id
  name    = "${var.profile}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web_app.public_ip]
}

#######################################
# Outputs
#######################################

# Outputs for S3 Bucket Name, EC2 Instance IP, and DNS
output "s3_bucket_name" {
  value = aws_s3_bucket.private_bucket.bucket
}

output "ec2_instance_public_ip" {
  value = aws_instance.web_app.public_ip
}

output "route53_dns" {
  value = "http://${var.profile}.${var.domain_name}:${var.application_port}/"
}
