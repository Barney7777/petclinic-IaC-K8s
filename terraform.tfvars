# environment Variables
project_name = "petclinic"
environment  = "dev"
region       = "ap-southeast-2"

# VPC variables
vpc_cidr                    = "192.168.0.0/16"
public_subnet_az1_cidr      = "192.168.0.0/24"
public_subnet_az2_cidr      = "192.168.1.0/24"
private_app_subnet_az1_cidr = "192.168.2.0/24"
private_app_subnet_az2_cidr = "192.168.3.0/24"

# EKS cluster variables
cluster_version = "1.29"

# Node group variables
desired_size   = 1
max_size       = 4
min_size       = 1
ami_type       = "AL2_x86_64"
instance_types = ["t3.large"]
capacity_type  = "SPOT"
# capacity_type = "ON_DEMAND"
disk_size = 80

# sg variables
ssh_location = "121.45.184.94/32"

# EC2 variables
instance_type_jumphost = "t2.micro"
key_name               = "myec2key"
instance_name          = "jumphost-server"

# acm variables
domain_name       = "barneywang.click"
alternative_names = "*.barneywang.click"

