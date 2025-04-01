output "apply_role_arn" {
  description = "ARN of the Terraform apply IAM role"
  value       = aws_iam_role.terraform_apply.arn
}

output "apply_role_name" {
  description = "Name of the Terraform apply IAM role"
  value       = aws_iam_role.terraform_apply.name
}

output "pull_request_role_arn" {
  description = "ARN of the Terraform pull request IAM role"
  value       = aws_iam_role.terraform_pull_request.arn
}

output "pull_request_role_name" {
  description = "Name of the Terraform pull request IAM role"
  value       = aws_iam_role.terraform_pull_request.name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}
