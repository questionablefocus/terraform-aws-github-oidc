variable "repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  type        = string
}

variable "apply_policy_arns" {
  description = "List of IAM policy ARNs to attach to the apply role"
  type        = list(string)
  default     = []
}

variable "pull_request_policy_arns" {
  description = "List of IAM policy ARNs to attach to the pull request role"
  type        = list(string)
  default     = []
}

variable "apply_role_arns" {
  description = "List of role ARNs that can be assumed by the apply role"
  type        = list(string)
  default     = []
}

variable "pull_request_role_arns" {
  description = "List of role ARNs that can be assumed by the pull request role"
  type        = list(string)
  default     = []
}
