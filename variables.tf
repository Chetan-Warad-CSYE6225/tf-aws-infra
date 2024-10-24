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
  description = "Port for ssh"
  type        = number
}

variable "protocol" {
  description = "Protocol"
  type        = string
}

variable "cidr_sg" {
  description = "CIDR for security group"
  type        = string
}

variable "ingress_eighty_port" {
  description = "Port for 80"
  type        = number
}

variable "ingress_443_port" {
  description = "Port for 443"
  type        = number
}

variable "egress_port" {
  description = "Port for egress"
  type        = number
}

variable "egress_protocol" {
  description = "Egress protocol"
  type        = string
}

variable "volume_size" {
  description = "Size of the volume"
  type        = number
}

variable "volume_type" {
  description = "Type of the volume"
  type        = string
}

variable "instance_type" {
  description = "Type of the instance"
  type        = string
}

variable "db_port" {
  description = "Port for the DB"
  type        = number
  default     = 5432 # PostgreSQL default port
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_family" {
  description = "The DB family for the parameter group"
  type        = string
  default     = "postgres13" # Set to postgres13
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "13.11" # PostgreSQL 13.7
}

variable "db_password" {
  description = "The master password for the database"
  type        = string
}

variable "engine_version" {
  description = "RDS Engine version"
  type        = string
}

variable "instance_class" {
  description = "RDS Instance class"
  type        = string
}

variable "allocated_storage" {
  description = "RDS allocated storage"
  type        = number
}

variable "username" {
  description = "RDS username"
  type        = string
}

variable "db_name" {
  description = "RDS db name"
  type        = string
}



