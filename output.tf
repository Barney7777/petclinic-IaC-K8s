output "db_secrets_role_arn" {
  value = aws_iam_role.db_secrets.arn
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
}

output "certificate_arn" {
  value = aws_acm_certificate.acm_certificate.arn
}