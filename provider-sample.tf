# aws configure --profile Setting
provider "aws" {
  region = "ap-northeast-2"
  profile = "default"
}

# aws access key
provider "aws" {
  region = "ap-northeast-2"
  access_key = "<acacess key>"
  secret_key = "<secret key>"
}
