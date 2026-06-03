resource "aws_iam_role" "this" {
  count = var.enable_iam_role ? 1 : 0

  name               = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
      
      dynamic "condition" {
        for_each = statement.value.conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "this" {
  count  = var.enable_iam_role ? 1 : 0

  name   = var.policy_name
  policy = data.aws_iam_policy_document.this.json
  tags   = var.policy_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.enable_iam_role ? 1 : 0
  
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_codestarconnections_connection" "this" {
  count = var.enable_source_github ? 1 : 0

  name          = "github-connection"
  provider_type = "GitHub"
}


resource "aws_codepipeline" "this" {
  name     = var.name
  pipeline_type = var.pipeline_type
  role_arn = aws_iam_role.this[0].arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.this.bucket
  }

  dynamic "stage" {
    for_each = var.enable_source_github ? [var.source_github_configuration] : []
    content {
      name = "Source"
      action {
        name             = "Source"
        category         = "Source"
        owner            = "ThirdParty"
        provider         = "GitHub"
        version          = "1"
        output_artifacts = ["source_output"]

        configuration = {
          Owner      = stage.value.owner
          Repo       = stage.value.repo
          Branch     = stage.value.branch
          OAuthToken = stage.value.oauthtoken
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_source_s3 ? [var.source_s3_configuration] : []
    content {
      name = "Source"
      action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "S3"
        version          = "1"
        output_artifacts = ["source_output"]

        configuration = {
          S3Bucket             = stage.value.bucket_name
          S3ObjectKey          = stage.value.s3_object_key
          PollForSourceChanges = stage.value.poll_for_source_changes
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_build && var.enable_codebuild ? [var.codebuild_name] : []
    content {
      name = "Build"
      action {
        name             = "Build"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output"]
        output_artifacts = ["build_output"]
        version          = "1"
        namespace        = "BuildVariables"

        configuration = {
          ProjectName = stage.value
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_approval ? [1] : []
    content {
      name = "Approval"

      action {
        name     = "ManualApproval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_deploy && var.enable_deploy_ec2 ? [var.deploy_ec2_configuration] : []
    content {
      name = "Deploy"

      action {
        name             = "Deploy"
        category         = "Deploy"
        owner            = "AWS"
        provider         = "CodeDeploy"
        input_artifacts  = var.enable_build ? ["build_output"] : ["source_output"]
        version          = "1"

        configuration = {
          ApplicationName     = stage.value.application_name
          DeploymentGroupName = stage.value.deployment_group_name
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_deploy && var.enable_deploy_ecs ? [var.deploy_ecs_configuration] : []
    content {
      name = "Deploy"
      action {
        name             = "Deploy"
        category         = "Deploy"
        owner            = "AWS"
        provider         = "CodeDeployToECS"
        input_artifacts  = var.enable_build ? ["build_output"] : ["source_output"]
        version          = "1"

        configuration = {
          ApplicationName                = stage.value.application_name
          DeploymentGroupName            = stage.value.deployment_group_name
          AppSpecTemplateArtifact        = var.enable_build ? ["build_output"] : ["source_output"]
          AppSpecTemplatePath            = stage.value.appspec_template_path
          TaskDefinitionTemplateArtifact = var.enable_build ? ["build_output"] : ["source_output"]
          TaskDefinitionTemplatePath     = stage.value.task_definition_template_path
        }
      }
    }
  }

  tags = var.tags
}