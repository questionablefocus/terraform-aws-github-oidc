variable "repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
}

variable "secondary_repositories" {
  description = "List of additional GitHub repositories in format owner/repo that should have access"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  type        = string
}

variable "backend_key" {
  description = "Key for the Terraform backend"
  type        = string
}

variable "read_write_policy_arns" {
  description = "List of IAM policy ARNs to attach to the read write role"
  type        = list(string)
  default     = []
}

variable "read_only_policy_arns" {
  description = "List of IAM policy ARNs to attach to the read only role"
  type        = list(string)
  default     = []
}

variable "read_write_role_arns" {
  description = "List of role ARNs that can be assumed by the read write role"
  type        = list(string)
  default     = []
}

variable "read_only_role_arns" {
  description = "List of role ARNs that can be assumed by the read only role"
  type        = list(string)
  default     = []
}

variable "read_write_policy_documents" {
  description = "List of IAM policy documents to attach to the read write role"
  type        = list(string)
  default     = []
}

variable "read_only_policy_documents" {
  description = "List of IAM policy documents to attach to the read only role"
  type        = list(string)
  default     = []
}

variable "allow_read_only_assume_role_arns" {
  description = "List of role ARNs which the read only role can assume"
  type        = list(string)
  default     = []
}

variable "allow_read_write_assume_role_arns" {
  description = "List of role ARNs which the read write role can assume"
  type        = list(string)
  default     = []
}
