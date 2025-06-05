provider "aws" {
    region = "il-central-1"
}

data "aws_instance" "elasticsearch01" {
  filter {
    name   = "tag:Name"
    values = ["elasticsearch01"]
  }
}

data "aws_instance" "elasticsearch02" {
  filter {
    name   = "tag:Name"
    values = ["elasticsearch02"]
  }
}

data "aws_lb" "imtec" {
  name = "imtec"
}

resource "aws_lb_listener" "imtec_http" {
    load_balancer_arn = data.aws_lb.imtec.arn
    port              = 8086 # need to check port
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.es_target_group.arn  # Forward traffic to target group
    }
}

data "aws_vpc" "imtech" {
  filter {
    name   = "tag:Name"
    values = ["imtech"]
  }
}

resource "aws_lb_target_group" "es_target_group" {
  name     = "amit-elastic-target-group"
  port     = 9200
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.imtech.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    path                = "/_cluster/health"
    port                = "9200"
    protocol            = "HTTP"
    matcher             = "200-299" # Elasticsearch usually returns 200 for /
  }

  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "es01" {
  target_group_arn = aws_lb_target_group.es_target_group.arn
  target_id        = data.aws_instance.elasticsearch01.id
  port             = 9200
}

resource "aws_lb_target_group_attachment" "es02" {
  target_group_arn = aws_lb_target_group.es_target_group.arn
  target_id        = data.aws_instance.elasticsearch02.id
  port             = 9200
}

# resource "aws_lb_listener_rule" "es_forward_rule" {
#   listener_arn = data.aws_lb_listener.imtec_http.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.es_target_group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/es*"] # Adjust the path condition as needed
#     }
#   }
# }

