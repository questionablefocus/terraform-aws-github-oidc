resource "aws_iam_role" "read_only" {
  name = "TerraformReadOnly"

  assume_role_policy = data.aws_iam_policy_document.read_only_github_oidc.json
}

data "aws_iam_policy_document" "read_only_github_oidc" {
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
      values   = ["repo:${var.repository}:pull_request"]
    }
  }
}

data "aws_iam_policy_document" "read_only" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]
    resources = [
      "${var.s3_bucket_arn}/${var.backend_key}.tflock"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:Get*",
      "iam:List*",
      "organizations:DescribeOrganization"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "read_only" {
  name        = "TerraformStateReadOnly"
  description = "Allows access to Terraform state and read-only access to other resources"
  policy      = data.aws_iam_policy_document.read_only.json
}

resource "aws_iam_role_policy_attachment" "read_only" {
  role       = aws_iam_role.read_only.name
  policy_arn = aws_iam_policy.read_only.arn
}

resource "aws_iam_role_policy_attachment" "read_only_additional" {
  count = length(var.read_only_policy_arns)

  role       = aws_iam_role.read_only.name
  policy_arn = var.read_only_policy_arns[count.index]
}

resource "aws_iam_policy" "read_only_additional" {
  count = length(var.read_only_policy_documents)

  name   = "TerraformReadOnlyAdditional-${count.index}"
  policy = var.read_only_policy_documents[count.index]
}

resource "aws_iam_role_policy_attachment" "read_only_additional_documents" {
  count = length(var.read_only_policy_documents)

  role       = aws_iam_role.read_only.name
  policy_arn = aws_iam_policy.read_only_additional[count.index].arn
}
