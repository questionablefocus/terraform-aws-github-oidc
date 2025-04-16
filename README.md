# terraform-aws-github-oidc

Terraform module to configure GitHub OIDC in an AWS account, and creates IAM roles for various use cases.

Roles are specific for use-cases: running `terraform plan` and `terraform apply`.

The `ReadOnly` roles have read-only permissions to resources and state files. Any user in the organization can use it to run `terraform plan`.

The `ReadWrite` roles have read and write permissions. These can only be used in GitHub Action workflows where the repositories are explicitly stated. The created `TerraformReadOnly` and `TerraformReadWrite` roles need to be explicited granted `assume-role` permissions.

## Releasing a new version

Create a git tag following semantic versioning.
