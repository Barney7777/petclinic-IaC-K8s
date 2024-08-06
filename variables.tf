# environment Variables
variable "region" {
  description = "region to create resources"
  type        = string
}

variable "project_name" {
  description = "project name"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

# VPC variables
variable "vpc_cidr" {
  description = "vpc cidr block"
  type        = string
}

variable "public_subnet_az1_cidr" {
  description = "public subnet az1 cidr block"
  type        = string
}

variable "public_subnet_az2_cidr" {
  description = "public subnet az2 cidr block"
  type        = string
}

variable "private_app_subnet_az1_cidr" {
  description = "private app subnet az1 cidr block"
  type        = string
}

variable "private_app_subnet_az2_cidr" {
  description = "private app subnet az2 cidr block"
  type        = string
}

# EKS cluster variable
variable "cluster_version" {
  description = "cluster version"
  type        = string
}

# node group variables
variable "desired_size" {
  description = "desired node group size"
  type        = number
}
variable "max_size" {
  description = "max node group size"
  type        = number
}
variable "min_size" {
  description = "min node group size"
  type        = number
}
variable "instance_types" {
  description = "instance types"
  type        = list(string)
}
variable "ami_type" {
  description = "ami_type"
  type        = string
}
variable "capacity_type" {
  description = "capacity_type"
  type        = string
}
variable "disk_size" {
  description = "disk_size"
  type        = number
}

# Security group variables
variable "ssh_location" {
  description = "ip address that can ssh into the serverr"
  type        = string
}

# EC2 variables
variable "instance_type_jumphost" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 keypair"
  type        = string
}

variable "instance_name" {
  description = "EC2 Instance name for the jenkins/bastionhost server"
  type        = string
}

# acm variables
variable "domain_name" {
  description = "domain_name"
  type        = string
}

variable "alternative_names" {
  description = "alternative_names"
  type        = string
}