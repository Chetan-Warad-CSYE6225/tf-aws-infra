variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zone_1" {
  description = "Availability zone 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability zone 2"
  type        = string
}

variable "availability_zone_3" {
  description = "Availability zone 3"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "public_subnet_3_cidr" {
  description = "CIDR block for public subnet 3"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for private subnet 3"
  type        = string
}

variable "profile" {
  description = "Used to represent the environment"
  type        = string
}

variable "custom_ami" {
  description = "Custom AMI for EC2 instance"
  type        = string
}

variable "application_port" {
  description = "Port on which the application runs"
  type        = number
}

variable "key_name" {
  description = "Name of the key pair for EC2 access"
  type        = string
}

variable "ingress_ssh_port" {
  description = "Port for SSH"
  type        = number
}

variable "protocol" {
  description = "Protocol for ingress and egress"
  type        = string
}

variable "cidr_sg" {
  description = "CIDR for security group"
  type        = string
}

variable "egress_port" {
  description = "Port for egress"
  type        = number
}

variable "egress_protocol" {
  description = "Egress protocol"
  type        = string
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

variable "db_password" {
  description = "The master password for the database"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route 53 record"
  type        = string
}

# Additional variables for RDS configuration
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "13.11"
}

variable "volume_type" {
  description = "The type of volume for the EC2 instance"
  type        = string
  default     = "gp2"
}


variable "db_family" {
  description = "Database family for RDS"
  type        = string
  default     = "postgres13"
}



variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "username" {
  description = "RDS username"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "allocated_storage" {
  description = "RDS allocated storage size in GB"
  type        = number
}

# Newly added variables for security group ingress ports
variable "ingress_eighty_port" {
  description = "Port for HTTP (80)"
  type        = number
  default     = 80
}

variable "ingress_443_port" {
  description = "Port for HTTPS (443)"
  type        = number
  default     = 443
}

# Newly added variables for EC2 instance volume size
variable "volume_size" {
  description = "Size of the EC2 instance volume"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "13.11"
}

# Additional variables for IAM and S3
variable "bucket_name" {
  description = "Name of the S3 bucket to store application data"
  type        = string
}

variable "iam_role_name" {
  description = "Name for the IAM role attached to EC2"
  type        = string
  default     = "EC2CloudWatchS3AccessRole"
}

variable "keyID" {
  description = "Access Key ID"
  type        = string
}

variable "key" {
  description = "Access key "
  type        = string
}