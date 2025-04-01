resource "aws_iam_role" "terraform_apply_assume" {
  count = length(var.apply_role_arns) > 0 ? 1 : 0
  name  = "TerraformApplyAssumeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = var.apply_role_arns
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_apply_assume_access" {
  count = length(var.apply_role_arns) > 0 ? length(var.apply_policy_arns) : 0

  role       = aws_iam_role.terraform_apply_assume[0].name
  policy_arn = var.apply_policy_arns[count.index]
}

resource "aws_iam_role_policy_attachment" "terraform_apply_assume_policies" {
  count = length(var.apply_role_arns) > 0 ? length(var.apply_policy_arns) : 0

  role       = aws_iam_role.terraform_apply_assume[0].name
  policy_arn = var.apply_policy_arns[count.index]
}
