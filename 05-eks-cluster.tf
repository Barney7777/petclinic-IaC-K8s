################ eks cluster iam ################
# assume role policy for eks cluster
data "aws_iam_policy_document" "assume_role_eks_cluster" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create eks cluster iam role
resource "aws_iam_role" "eks_cluster_iam_role" {
  name               = "${var.project_name}-${var.environment}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks_cluster.json
}

# create and attach eks cluster iam policy
resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_iam_role.name
}

# create and attach eks cluster iam policy
resource "aws_iam_role_policy_attachment" "elb_fullaccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.eks_cluster_iam_role.name
}

#create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-${var.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster_iam_role.arn
  version  = var.cluster_version

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids = [
      aws_subnet.private_subnet_az1.id,
      aws_subnet.private_subnet_az2.id
    ]
  }

  # configure authentication. manage access to EKS
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.elb_fullaccess
  ]
}