resource "aws_codecommit_repository" "test" {
  repository_name = var.name
  kms_key_id      = try(var.kms_key_id, null)

  tags = var.tags
}