# terraform-aws-github-oidc

Terraform module to configure GitHub OIDC in an AWS account, and creates IAM roles for various use cases.

- `TerraformReadOnly`: to be used in GitHub Actions triggered by a Pull Request (to run `terraform plan`)
- `TerraformReadWrite`: to be used in GitHub Actions triggered by a push to the default / deployment branch (to run `terraform apply`)

This module also supports separate AWS accounts for storing Terraform state. Use

- `TerraformReadOnlyAssume` role: assume this role in the Terraform backend of another GitHub repository to run `terraform plan`
- `TerraformReadWriteAssume` role: assume this role in the Terraform backend of another GitHub repository to run `terraform apply`

The permissions for each `*Assume` role is identical to its respective base IAM role.

IAM Users of the organisation is allowed to assume the read-only role for running `terraform plan` locally. They are **not** allowed to assume the read-write role.

## Examples

Here we present a couple of examples:

### Basic configuration

```hcl
module "github_oidc" {
  source  = "app.terraform.io/questionable-focus/github-oidc/aws"
  version = "1.3.0"

  repository    = "some-github-repository-name"
  s3_bucket_arn = "arn:aws:s3:::<some-bucket-name>"
  backend_key   = "some-terraform-backend-key.tfstate"

  read_only_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  read_write_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}
```

The `read_only_policy_arns` and `read_write_policy_arns` variables allow for customisation of permissions. The above example provides a pragmatic set of permissions for each role, however, more security inclined organisations might choose to be very explicit. In these cases, `read_only_policy_documents` and `read_write_policy_documents` variables can be used for convenience.

### Allowing roles to be assumed

When having a multi-account setup e.g. when Terraform states are stored in a specific AWS account, separate from other AWS accounts, we have to grant `assume-role` permissions on both accounts.

In the AWS account which stores the Terraform states, specify the relevant role ARNs from other AWS accounts:

```hcl
module "github_oidc" {
  source  = "app.terraform.io/questionable-focus/github-oidc/aws"
  version = "1.3.0"

  repository    = "some-github-repository-name"
  s3_bucket_arn = "arn:aws:s3:::<some-bucket-name>"
  backend_key   = "some-terraform-backend-key.tfstate"

  read_only_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  read_write_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  read_only_role_arns = ["arn:aws:iam::<another-aws-account-number>:role/TerraformReadOnly"]
  read_write_role_arns = ["arn:aws:iam::<another-aws-account-number>:role/TerraformReadWrite"]
}
```

Then in other AWS accounts specify the Terraform AWS account ARNs:

```hcl
module "github_oidc" {
  source  = "app.terraform.io/questionable-focus/github-oidc/aws"
  version = "1.3.0"

  repository    = "some-github-repository-name"
  s3_bucket_arn = "arn:aws:s3:::<some-bucket-name>"
  backend_key   = "some-terraform-backend-key.tfstate"

  read_only_policy_arns  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  read_write_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  allow_read_only_assume_role_arns  = ["arn:aws:iam::<terraform-state-aws-account-number>:role/TerraformReadOnlyAssume"]
  allow_read_write_assume_role_arns = ["arn:aws:iam::<terraform-state-aws-account-number>:role/TerraformReadWriteAssume"]
}
```

This provides explicit granting of `assume-role` permissions in code. Used together with Pull Requests and Reviews, we can have a pragmatic approach to a self-serving change management process.

### Grant other repositories access

If you would like other repositories to be allowed to use these IAM roles, use the `secondary_repositories` variable. The format should be the same as the primary `repository` variable.

## Versioning

Semantic versioning is used, and git tags are pushed whenever a new version is ready for release.
