resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"

  # This is the AssumeRole policy that allows EC2 to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "aws-assume-role"
    }
  )
}


resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_instance_policy"
  description = "Allow EC2 to describe instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:Describe*"]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "aws-ec2-policy"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "aws_instance_profile_test"
  role = aws_iam_role.ec2_instance_role.name
}

# IAM Instance Profile for EC2 instances
resource "aws_iam_instance_profile" "ip" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_instance_role.name

  tags = merge(
    var.tags,
    { Name = "ec2_instance_profile" }
  )
}
