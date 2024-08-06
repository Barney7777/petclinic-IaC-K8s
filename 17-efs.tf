# resource "aws_efs_file_system" "eks" {
#   creation_token = "eks"

#   performance_mode = "generalPurpose"
#   throughput_mode  = "bursting"
#   encrypted        = true

#   # lifecycle_policy {
#   #   transition_to_ia = "AFTER_30_DAYS"
#   # }
# }

# resource "aws_efs_mount_target" "private_subnet_az1" {
#   file_system_id  = aws_efs_file_system.eks.id
#   subnet_id       = aws_subnet.private_subnet_az1.id
#   security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id] # open a firewall for those workers to connect to the file system
# }

# resource "aws_efs_mount_target" "private_subnet_az2" {
#   file_system_id  = aws_efs_file_system.eks.id
#   subnet_id       = aws_subnet.private_subnet_az2.id
#   security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id] # open a firewall for those workers to connect to the file system
# }

# # create trust policy and specify the efs csi driver kubernetes service account and namespace
# data "aws_iam_policy_document" "efs_csi_driver" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# # create a role for efs csi driver
# resource "aws_iam_role" "efs_csi_driver" {
#   name               = "${aws_eks_cluster.eks_cluster.name}-efs-csi-driver"
#   assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
# }

# # attach efs csi driver policy to the role
# resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
#   role       = aws_iam_role.efs_csi_driver.name
# }

# resource "helm_release" "efs_csi_driver" {
#   name = "aws-efs-csi-driver"

#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   namespace  = "kube-system"
#   version    = "3.0.5"

#   set {
#     name  = "controller.serviceAccount.name"
#     value = "efs-csi-controller-sa"
#   }

#   set {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.efs_csi_driver.arn
#   }

#   depends_on = [
#     aws_efs_mount_target.private_subnet_az1,
#     aws_efs_mount_target.private_subnet_az2
#   ]
# }

# # Optional since we already init helm provider (just to make it self contained)
# data "aws_eks_cluster" "eks_v2" {
#   name = aws_eks_cluster.eks_cluster.name
# }

# # Optional since we already init helm provider (just to make it self contained)
# data "aws_eks_cluster_auth" "eks_v2" {
#   name = aws_eks_cluster.eks_cluster.name
# }

# # we will use new kubernetes terraform provider to create a customer kubernetes
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.eks_v2.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_v2.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_v2.token
# } 

# resource "kubernetes_storage_class_v1" "efs" {
#   metadata {
#     name = "efs"
#   }

#   storage_provisioner = "efs.csi.aws.com"

#   parameters = {
#     provisioningMode = "efs-ap"
#     fileSystemId     = aws_efs_file_system.eks.id
#     directoryPerms   = "700"
#   }

#   mount_options = ["iam"]

#   depends_on = [helm_release.efs_csi_driver]
# }
