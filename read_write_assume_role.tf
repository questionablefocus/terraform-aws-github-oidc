data "aws_iam_policy_document" "read_write_assume_role" {
  statement {
    sid     = "AllowAssumeRoleFromGitHubActions"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.read_write_role_arns
    }
  }
}

resource "aws_iam_role" "read_write_assume_role" {
  count = length(var.read_write_role_arns) > 0 ? 1 : 0

  name = "TerraformReadWriteAssume"

  assume_role_policy = data.aws_iam_policy_document.read_write_assume_role.json
}

resource "aws_iam_role_policy_attachment" "read_write_assume_access" {
  count = length(var.read_write_role_arns) > 0 ? 1 : 0

  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = aws_iam_policy.read_write.arn
}

// Attach additional policies to the read write role
resource "aws_iam_role_policy_attachment" "read_write_assume_policies" {
  count = length(var.read_write_role_arns) > 0 ? length(var.read_write_policy_arns) : 0

  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = var.read_write_policy_arns[count.index]
}

// Attach additional policy documents to the read write role
resource "aws_iam_policy" "read_write_assume_additional" {
  count = length(var.read_write_role_arns) > 0 ? length(var.read_write_policy_documents) : 0

  name   = "TerraformReadWriteAssumeAdditional-${count.index}"
  policy = var.read_write_policy_documents[count.index]
}

resource "aws_iam_role_policy_attachment" "read_write_assume_additional_documents" {
  count = length(var.read_write_role_arns) > 0 ? length(var.read_write_policy_documents) : 0

  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = aws_iam_policy.read_write_assume_additional[count.index].arn
}

// Allow var.allow_read_write_assume_role_arns to assume the read write role
data "aws_iam_policy_document" "allow_read_write_assume_role" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = var.allow_read_write_assume_role_arns
  }
}

resource "aws_iam_policy" "allow_read_write_assume_role" {
  count = length(var.read_write_role_arns) > 0 ? 1 : 0

  name = "AllowReadWriteAssumeRole"

  policy = data.aws_iam_policy_document.allow_read_write_assume_role.json
}

resource "aws_iam_role_policy_attachment" "allow_read_write_assume_access" {
  count = length(var.read_write_role_arns) > 0 ? 1 : 0

  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = aws_iam_policy.allow_read_write_assume_role[0].arn
}
