resource "aws_s3_bucket" "s3" {
    bucket = "<S3>"
s
    tags = {
        Name = "<S3>"
    } 
}

output "s3" {
    value = aws_s3_bucket.s3.id
}