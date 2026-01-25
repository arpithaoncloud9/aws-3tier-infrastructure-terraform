resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt"
  image_id      = "ami-08d7aabbb50c2c24e" # Amazon Linux 2
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Welcome to Day-2 Maria's App Server" > /var/www/html/index.html
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-server"
    }
  }
}
