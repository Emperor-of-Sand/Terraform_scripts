# Datasource to fetch availability zones
data "aws_availability_zones" "available" {}

# Provider configuration
provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "company-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "company-igw"
  }
}
# Subnets
resource "aws_subnet" "main" {
  count                   = length(var.subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnet_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "company-subnet-${count.index + 1}"
  }
}

# Route Table and Associations
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  count          = length(var.subnet_cidr)
  subnet_id      = element(aws_subnet.main[*].id, count.index)
  route_table_id = aws_route_table.rt.id
}

# Security Groups
resource "aws_security_group" "allow_http" {
  name   = "allow_http"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "allow_http_sg"
  }
}

# Launch configuration 
resource "aws_launch_configuration" "web" {
  name_prefix                 = "web-server-lc"
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.allow_http.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "aug" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 2
  vpc_zone_identifier  = aws_subnet.main[*].id
  launch_configuration = aws_launch_configuration.web.id

  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = true
  }
}

# Load Balancer
resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = aws_subnet.main[*].id
  security_groups = [aws_security_group.allow_http.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 30
  }
  tags = {
    Name = "web-elb"
  }
}

# Attach Auto Scaling Group to Load Balancer
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.aug.name
  elb                    = aws_elb.web.id
}


# Scaling Policies
# CloudWatch Alarms for scaling down and up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.aug.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.aug.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
}
##########################################################
# CloudWatch Alarms for Auto Scaling
##########################################################
# These alarms will trigger the scaling policies based on CPU utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors high CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aug.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "This metric monitors low CPU utilization"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aug.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}

output "elb_dns_name" {
  value       = aws_elb.web.dns_name
  description = "The DNS name of the ELB"
}
