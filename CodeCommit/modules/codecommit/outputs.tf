output "codecommit_repository_name" {
  value = aws_codecommit_repository.this.repository_name
}

output "codecommit_repository_arn" {
  value = aws_codecommit_repository.this.arn
}

output "codecommit_repository_id" {
  value = aws_codecommit_repository.this.repository_id
}

output "codecommit_repository_url" {
  value = aws_codecommit_repository.this.clone_url_http
}