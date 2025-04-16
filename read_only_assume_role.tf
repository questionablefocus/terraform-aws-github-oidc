resource "aws_iam_role" "read_only_assume_role" {
  name = "TerraformReadOnlyAssume"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      length(var.read_only_role_arns) > 0 ? [
        {
          Sid    = "AllowAssumeRoleFromGitHubActions"
          Effect = "Allow"
          Principal = {
            AWS = var.read_only_role_arns
          }
          Action = "sts:AssumeRole"
        }
      ] : [],
      [
        {
          Sid    = "AllowAssumeRoleFromOrganization"
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "aws:PrincipalOrgID" : data.aws_organizations_organization.current.id
            }
          }
        }
      ]
    )
  })
}

resource "aws_iam_role_policy_attachment" "read_only_assume_access" {
  role       = aws_iam_role.read_only_assume_role.name
  policy_arn = aws_iam_policy.read_only.arn
}

resource "aws_iam_role_policy_attachment" "read_only_assume_policies" {
  count = length(var.read_only_policy_arns)

  role       = aws_iam_role.read_only_assume_role.name
  policy_arn = var.read_only_policy_arns[count.index]
}

resource "aws_iam_policy" "read_only_assume_additional" {
  count = length(var.read_only_policy_documents)

  name   = "TerraformReadOnlyAssumeAdditional-${count.index}"
  policy = var.read_only_policy_documents[count.index]
}

resource "aws_iam_role_policy_attachment" "read_only_assume_additional_documents" {
  count = length(var.read_only_policy_documents)

  role       = aws_iam_role.read_only_assume_role.name
  policy_arn = aws_iam_policy.read_only_assume_additional[count.index].arn
}
