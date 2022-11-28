data "aws_iam_policy_document" "ec2_code_deploy_policy" {
   statement {
      actions = [
         "s3:Get*",
         "s3:List*"
      ]
      
      resources = [
         # "arn:aws:s3:::${aws_s3_bucket.artifacts_bucket.name}/*", 
         "arn:aws:s3:::${var.s3_bucket_name}/*",
         "arn:aws:s3:::aws-codedeploy-${var.region}/*"
      ]
   }
}

resource "aws_iam_role" "ec2_code_deploy_instance_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "EC2CodeDeployPolicy"
    policy = data.aws_iam_policy_document.ec2_code_deploy_policy.json
  }
}

resource "aws_iam_instance_profile" "ec2_code_deploy_instance_profile" {
   name = "EC2CodeDeployInstanceProfile"
   role = aws_iam_role.ec2_code_deploy_instance_role.name
}

resource "aws_iam_role" "aws_codedeploy_role" {
  name = "example-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
            "Service": "codedeploy.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codeDeploy_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.aws_codedeploy_role.name
}