# create iam role for eks node group
data "aws_iam_policy_document" "assume_role_node_group" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create iam role for eks node group
resource "aws_iam_role" "eks_node_group_iam_role" {
  name               = "${var.project_name}-${var.environment}-eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_node_group.json
}

# create iam role policy attachment for eks node group
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_iam_role.name
}

# create iam role policy attachment for eks node group to manage secondary ips in the pods
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_iam_role.name
}

# create iam role policy attachment for eks node group
resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_iam_role.name
}

# create node-group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_iam_role.arn

  # Identifiers of EC2 Subnets to associate with the EKS Node Group. 
  # These subnets must have the following resource tag: kubernetes.io/cluster/EKS_CLUSTER_NAME 
  subnet_ids = [
    aws_subnet.private_subnet_az1.id,
    aws_subnet.private_subnet_az2.id
  ]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  ami_type      = var.ami_type
  capacity_type = var.capacity_type
  disk_size     = var.disk_size
  # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  force_update_version = false
  instance_types       = var.instance_types
  labels = {
    role = "${var.project_name}-${var.environment}-eks-node-group-role" # migrate applications from one node group to anpther with the same labels
    name = "${var.project_name}-${var.environment}-eks-node-group"
  }

  # allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly
  ]
}