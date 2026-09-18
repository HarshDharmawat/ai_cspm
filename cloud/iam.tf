resource "aws_iam_role" "web_ec2_role" {
  name = "payvault-web-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# permission 1: allow EC2 to pull images from ECR without static API keys
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role = aws_iam_role.web_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# permission 2 (Intentional CSPM Flaw): Over-privileged S3 access
resource "aws_iam_policy" "toxic_s3_policy" {
  name = "ToxicS3WildcardPolicy"
  description = "Intentional over-privileged access for CSPM detection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "toxic_s3_attach" {
  role = aws_iam_role.web_ec2_role.name
  policy_arn = aws_iam_policy.toxic_s3_policy.arn
}

resource "aws_iam_instance_profile" "web_profile" {
  name = "payvault-web-instance-profile"
  role = aws_iam_role.web_ec2_role.name
}