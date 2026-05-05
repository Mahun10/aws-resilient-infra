data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd amazon-ssm-agent awscli

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

rm -rf /var/www/html/*

aws s3 sync s3://${aws_s3_bucket.static_site_assets.bucket}/ /var/www/html/

chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

systemctl enable httpd
systemctl restart httpd
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-ec2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_profile.name
  }

  depends_on = [
    aws_s3_object.index_html,
    aws_iam_role_policy.ec2_s3_read_static_site
  ]
}

resource "aws_iam_role_policy" "ec2_s3_read_static_site" {
  name = "${var.project_name}-ec2-s3-read-static-site"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.static_site_assets.arn,
          "${aws_s3_bucket.static_site_assets.arn}/*"
        ]
      }
    ]
  })
}