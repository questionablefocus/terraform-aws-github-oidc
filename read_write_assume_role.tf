resource "aws_iam_role" "read_write_assume_role" {
  count = length(var.read_write_role_arns) > 0 ? 1 : 0
  name  = "TerraformReadWriteAssume"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = var.read_write_role_arns
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "read_write_assume_access" {
  count      = length(var.read_write_role_arns) > 0 ? 1 : 0
  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = aws_iam_policy.read_write.arn
}

resource "aws_iam_role_policy_attachment" "read_write_assume_policies" {
  count = length(var.read_write_role_arns) > 0 ? length(var.read_write_policy_arns) : 0

  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = var.read_write_policy_arns[count.index]
}

resource "aws_iam_policy" "read_write_additional" {
  count = length(var.read_write_role_arns) > 0 ? length(var.read_write_policy_documents) : 0

  name   = "TerraformReadWriteAssumeAdditional-${count.index}"
  policy = var.read_write_policy_documents[count.index]
}

resource "aws_iam_role_policy_attachment" "read_write_additional_documents" {
  count = length(var.read_write_role_arns) > 0 ? length(var.read_write_policy_documents) : 0

  role       = aws_iam_role.read_write_assume_role[0].name
  policy_arn = aws_iam_policy.read_write_additional[count.index].arn
}
