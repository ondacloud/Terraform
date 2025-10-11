locals {
  iams = {
    "ec2-policy" = {
      statements = [
        {
          effect    = "Allow"
          actions   = ["ec2:*"]
          resources = ["*"]
          conditions = [] 
        }
      ]

      policy_tags = {
        Name = "ec2-policy"
      }
    },
    
    "ec2-read-only-policy" = {
      statements = [
        {
          effect    = "Allow"
          actions   = ["ec2:Describe*"]
          resources = ["*"]
          
          conditions = [
            {test = "StringEquals", variable = "*:ResourceTag/owner", values = ["$${aws.username}"]}
          ]
        }
      ]

      policy_tags = {
        Name = "ec2-read-only-policy"
      }
    },
  }
}