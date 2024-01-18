# aws configure --profile Setting
provider "aws" {
  region = "ap-northeast-2"
  profile = "<Profile>"
}

# aws access key
provider "aws" {
  access_key = "<Access_Key>"
  secret_key = "<Secret_Key>"
  region = "ap-northeast-2"
}