resource "aws_iam_role" "role" {
  name = "<env>-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["<Service Name>:Describe*"]
    resources = ["*"]
  }
}

output "iam-role" {
  value = aws_iam_role.role.name
}