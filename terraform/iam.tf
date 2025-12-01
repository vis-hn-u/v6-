resource "aws_iam_role" "ec2_role" {
  name = "careconnect_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "devops_policy" {
  name = "devops_policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:List*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "careconnect_ec2_profile"
  role = aws_iam_role.ec2_role.name
}
