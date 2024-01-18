# aws configure --profile Setting
provider "aws" {
  region = "ap-northeast-2"
  profile = "default"
}

# aws access key
provider "aws" {
  access_key = "<access_key>"
  secret_key = "<secret_key>"
  region = "ap-northeast-2"
}