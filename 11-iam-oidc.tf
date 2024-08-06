# This data block retrieves the TLS certificate for the EKS cluster and assigns it to the variable data.tls_certificate.eks
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

#OpenID Connect provider in AWS IAM. It allows IAM roles to trust and authenticate using the OpenID Connect (OIDC) protocol. 
#The client_id_list specifies the allowed client IDs, and the thumbprint_list specifies the SHA-1 fingerprint of the TLS certificate.
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}