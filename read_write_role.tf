resource "aws_iam_role" "read_write" {
  name = "TerraformReadWrite"

  assume_role_policy = data.aws_iam_policy_document.read_write_github_oidc.json
}

data "aws_iam_policy_document" "read_write_github_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.repository}:ref:refs/heads/main"]
    }
  }
}

data "aws_iam_policy_document" "read_write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:*",
      "organizations:DescribeOrganization"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "read_write" {
  name        = "TerraformStateWriteAccess"
  description = "Allows access to Terraform state S3 bucket"
  policy      = data.aws_iam_policy_document.read_write.json
}

resource "aws_iam_role_policy_attachment" "read_write" {
  role       = aws_iam_role.read_write.name
  policy_arn = aws_iam_policy.read_write.arn
}

resource "aws_iam_role_policy_attachment" "read_write_additional" {
  count = length(var.read_write_policy_arns)

  role       = aws_iam_role.read_write.name
  policy_arn = var.read_write_policy_arns[count.index]
}

resource "aws_iam_policy" "read_write_additional" {
  count = length(var.read_write_policy_documents)

  name   = "TerraformReadWriteAdditional-${count.index}"
  policy = var.read_write_policy_documents[count.index]
}

resource "aws_iam_role_policy_attachment" "read_write_additional_documents" {
  count = length(var.read_write_policy_documents)

  role       = aws_iam_role.read_write.name
  policy_arn = aws_iam_policy.read_write_additional[count.index].arn
}

// Allow the read write role to assume var.allow_read_write_assume_role_arns
data "aws_iam_policy_document" "allow_read_write_role" {
  count = length(var.allow_read_write_assume_role_arns) > 0 ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = var.allow_read_write_assume_role_arns
  }
}

resource "aws_iam_policy" "allow_read_write_role" {
  count = length(var.allow_read_write_assume_role_arns) > 0 ? 1 : 0

  name   = "AllowReadWriteAssumeRole"
  policy = data.aws_iam_policy_document.allow_read_write_role[0].json
}

resource "aws_iam_role_policy_attachment" "allow_read_write_access" {
  count = length(var.allow_read_write_assume_role_arns) > 0 ? 1 : 0

  role       = aws_iam_role.read_write.name
  policy_arn = aws_iam_policy.allow_read_write_role[0].arn
}
