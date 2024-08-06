resource "helm_release" "secrets_csi_driver" {
  name = "secrets-store-csi-driver"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = "1.4.3"

  # MUST be set if you use ENV variables
  set {
    name  = "syncSecret.enabled"
    value = true
  }

  depends_on = [aws_eks_node_group.node_group]
}

# install a cloud specific provider
resource "helm_release" "secrets_csi_driver_aws_provider" {
  name = "secrets-store-csi-driver-provider-aws"

  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = "0.3.9"

  depends_on = [helm_release.secrets_csi_driver]
}

# create trust policy for application that needs access to a specific secret
data "aws_iam_policy_document" "db_secrets" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:petclinic:db-secret-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

# create iam role for this specific application
resource "aws_iam_role" "db_secrets" {
  name               = "${aws_eks_cluster.eks_cluster.name}-db-secrets"
  assume_role_policy = data.aws_iam_policy_document.db_secrets.json
}

# create policy for the role
resource "aws_iam_policy" "db_secrets" {
  name = "${aws_eks_cluster.eks_cluster.name}-db-secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*" # "arn:*:secretsmanager:*:*:secret:my-secret-kkargS"
      }
    ]
  })
}

# attach policy to the role
resource "aws_iam_role_policy_attachment" "db_secrets" {
  policy_arn = aws_iam_policy.db_secrets.arn
  role       = aws_iam_role.db_secrets.name
}
