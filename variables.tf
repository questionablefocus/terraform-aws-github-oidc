variable "repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
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
