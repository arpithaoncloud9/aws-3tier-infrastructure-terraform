# Security groups
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "App security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# ALB
resource "aws_lb" "app_alb" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target groups
resource "aws_lb_target_group" "app1_tg" {
  name     = "${var.project_name}-app1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/app1"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-app1-tg"
  }
}

resource "aws_lb_target_group" "app2_tg" {
  name     = "${var.project_name}-app2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/app2"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-app2-tg"
  }
}

# Listener + path-based rules
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "nodejs_tg" {
  name     = "${var.project_name}-nodejs-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/app2"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-nodejs-tg"
  }
}


resource "aws_lb_listener_rule" "app1_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1_tg.arn
  }

  condition {
    path_pattern {
      values = ["/app1*"]
    }
  }
}

resource "aws_lb_listener_rule" "app2_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app2_tg.arn
  }

  condition {
    path_pattern {
      values = ["/app2*"]
    }
  }
}

resource "aws_lb_listener_rule" "app2_node_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodejs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/app2*"]
    }
  }
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2-ssm-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ssm-cloudwatch-profile"
  role = aws_iam_role.ec2_role.name
}



resource "aws_launch_template" "app1_lt" {
  name_prefix   = "app1-lt-"
  image_id      = "ami-024ee5112d03921e2"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd amazon-cloudwatch-agent

# Start SSM Agent (already installed on AL2)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# CloudWatch Agent config
cat <<CWCONFIG > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "append_dimensions": {
    "InstanceId": "$${aws:InstanceId}"
},
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "cpu": { "measurement": ["cpu_usage_idle"] }
    }
  }
}
CWCONFIG

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# APP1 content
mkdir -p /var/www/html/app1
echo "Welcome to Maria's APP1 🚀" > /var/www/html/app1/index.html

cat <<EOT > /etc/httpd/conf.d/app1.conf
Alias /app1 /var/www/html/app1
<Directory /var/www/html/app1>
    Require all granted
</Directory>
EOT

systemctl enable httpd
systemctl restart httpd
EOF
  )
}

resource "aws_launch_template" "app2_lt" {
  name_prefix   = "app2-lt-"
  image_id      = "ami-024ee5112d03921e2"
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
yum update -y
yum install -y httpd amazon-cloudwatch-agent

# Start SSM Agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# CloudWatch Agent config
cat <<CWCONFIG > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "append_dimensions": {
    "InstanceId": "$${aws:InstanceId}"
},
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "cpu": { "measurement": ["cpu_usage_idle"] }
    }
  }
}
CWCONFIG

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# APP2 content
mkdir -p /var/www/html/app2
echo "Welcome to Maria's APP2 ⚡" > /var/www/html/app2/index.html

cat <<EOT > /etc/httpd/conf.d/app2.conf
Alias /app2 /var/www/html/app2
<Directory /var/www/html/app2>
    Require all granted
</Directory>
EOT

systemctl enable httpd
systemctl restart httpd
EOF
  )
}



# ASG for app1
resource "aws_autoscaling_group" "app1_asg" {
  name                      = "${var.project_name}-app1-asg"
  desired_capacity          = var.desired_capacity_app1
  max_size                  = var.max_size_app1
  min_size                  = var.min_size_app1
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app1_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app1_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app1"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ASG for app2
resource "aws_autoscaling_group" "app2_asg" {
  name                      = "${var.project_name}-app2-asg"
  desired_capacity          = var.desired_capacity_app2
  max_size                  = var.max_size_app2
  min_size                  = var.min_size_app2
  vpc_zone_identifier       = var.private_subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app2_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app2_tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
