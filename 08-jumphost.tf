# Create iam role for jumphost
data "aws_iam_policy_document" "assume_role_jumphost" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
# Create the IAM role using the policy document defined in the data source
resource "aws_iam_role" "jumphost_execution_role" {
  name               = "${var.project_name}-${var.environment}-jumphost-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_jumphost.json
}

# Attach the AWS managed policy (AdministratorAccess) to the IAM role
resource "aws_iam_role_policy_attachment" "jumphost_policy_attachment" {
  role       = aws_iam_role.jumphost_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create an IAM instance profile and associate it with the IAM role
resource "aws_iam_instance_profile" "jumphost_execution_profile" {
  name = "${var.project_name}-${var.environment}-jumphost-execution-profile"
  role = aws_iam_role.jumphost_execution_role.name
}

data "aws_ami" "ubuntu22" {
  most_recent = true
  owners      = ["amazon"] # Canonical's AWS Account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu22.image_id
  instance_type          = var.instance_type_jumphost
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.bastion_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.jumphost_execution_profile.name
  root_block_device {
    volume_size = 20
  }
  user_data = templatefile("./install.sh", {})

  tags = {
    Name = var.instance_name
  }
}