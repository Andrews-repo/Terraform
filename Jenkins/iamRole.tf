#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
#Create a role
resource "aws_iam_role" "Terraform_role" {
  name = "Terraform_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#Create a Policy
resource "aws_iam_policy" "Terraform_policy" {
  name        = "Terraform_policy"
  description = "Allows an EC2 instance to call AWS service to complete Terraform scripts"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "Terraform_attach" {
  role       = aws_iam_role.Terraform_role.id
  policy_arn = aws_iam_policy.Terraform_policy.arn
}

#Attach role to an instance profile
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "Terraform_profile" {
  name = "ec2_profile"
  role = aws_iam_role.Terraform_role.name
}
