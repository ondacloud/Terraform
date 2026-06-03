#!/bin/bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION_CODE="ap-northeast-2"
ECR_REPO_NAME="demo-repo"
IMAGE_TAG=$(aws ecr describe-images --repository-name $ECR_REPO_NAME --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' --output text)
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION_CODE.amazonaws.com/$ECR_REPO_NAME:$IMAGE_TAG"

docker pull $ECR_URI:$IMAGE_TAG
docker run -d -p 8080:8080 --name demo-cnt $ECR_URI:$IMAGE_TAG