data "aws_iam_policy_document" "read_only_assume_role" {
  dynamic "statement" {
    for_each = length(var.read_only_role_arns) > 0 ? [1] : []

    content {
      sid     = "AllowAssumeRoleFromGitHubActions"
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = var.read_only_role_arns
      }
    }
  }

  statement {
    sid     = "AllowAssumeRoleFromOrganization"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.current.id]
    }
  }
}

resource "aws_iam_role" "read_only_assume_role" {
  name = "TerraformReadOnlyAssume"

  assume_role_policy = data.aws_iam_policy_document.read_only_assume_role.json
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
