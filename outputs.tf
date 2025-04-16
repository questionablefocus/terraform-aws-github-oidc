output "read_write_role_arn" {
  description = "ARN of the Terraform read write IAM role"
  value       = aws_iam_role.read_write.arn
}

output "read_write_role_name" {
  description = "Name of the Terraform read write IAM role"
  value       = aws_iam_role.read_write.name
}

output "read_only_role_arn" {
  description = "ARN of the Terraform read only IAM role"
  value       = aws_iam_role.read_only.arn
}

output "read_only_role_name" {
  description = "Name of the Terraform read only IAM role"
  value       = aws_iam_role.read_only.name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
