provider "aws" {                # The platform I work on
    region = var.region     # The region I work on
}

terraform {
  backend "s3" {
    bucket = "imtec-tf-backend"
    key = "amit"
    region = "il-central-1"
  }
}

resource "aws_launch_template" "amit_template" {
  name_prefix   = "amit-launch-template-"  # Terraform will auto-add random suffix
  image_id      = var.ami-id   # <-- Choose an AMI ID for your region
  instance_type = "t3.micro"                # Or another type you want

  network_interfaces {
    associate_public_ip_address = false     # Or true if you want public IPs
    subnet_id                    = var.subnet-1 # One of your subnets
    security_groups              = [var.security-group]   # <-- Your security group
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Amit-ASG"
    }
  }
}

data "aws_lb_target_group" "umat_haash" { # Fetch the target group
  name = "tg-umat-haash"
}

resource "aws_autoscaling_group" "example" {
  name                      = "amit-example-asg-${count.index + 1}"
  count                     = 3
  desired_capacity          = 0
  min_size                  = 0
  max_size                  = 3
  vpc_zone_identifier       = [var.subnet-1, var.subnet-2]  # My private subnets

  launch_template {
    id      = aws_launch_template.amit_template.id    # Chosen launch template from data
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [data.aws_lb_target_group.umat_haash.arn]

  tag {
    key                 = "Name"
    value               = var.auto-scale-name-tag
    propagate_at_launch = true
  }
}

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:Name"
    values = [var.auto-scale-name-tag]
  }

  instance_state_names = ["running"]
}