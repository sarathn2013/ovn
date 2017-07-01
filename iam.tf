# Creating IAM Role for opsworks
resource "aws_iam_role" "opsworks-service-role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
               "Service": "opsworks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "opsworks" {
  name = "opsworks-role-policy"
  role = "${aws_iam_role.opsworks-service-role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
   "Statement": [
        {
            "Action": [
                "ec2:*",
                "iam:PassRole",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:DescribeAlarms",
                "ecs:*",
                "elasticloadbalancing:*",
                "rds:*"
                
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

# Creating IAM Role for opsworks
resource "aws_iam_role" "opsworks-ec2-role" {
  name = "ec2-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# creating IAM profile
resource "aws_iam_instance_profile" "opsworks2" {
  name = "opsworks2"
  role = "${aws_iam_role.opsworks-ec2-role.name}"
}
