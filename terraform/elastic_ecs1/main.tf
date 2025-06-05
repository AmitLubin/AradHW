provider "aws" {
  region = "il-central-1"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["imtech"] 
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id" # Change
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

data "aws_ecs_cluster" "main" {
  cluster_name = "imtech"
}

data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["launch-wizard-4"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_lb" "imtec_alb" {
  name = "imtec"
}

resource "aws_cloudwatch_log_group" "filebeat" {
  name              = "/ecs/filebeat/amit-nginx-filebeat"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "nginx_filebeat" {
  family                   = "namit-ginx-filebeat-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::314525640319:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        protocol      = "tcp"
      }]
      mountPoints = [{
        sourceVolume  = "amit-shared-logs"
        containerPath = "/var/log/nginx"
      }]
    },
    {
      name      = "filebeat"
      image     = "amitlubin/filebeat-from-nginx:v4" # Change
      essential = false
      mountPoints = [{
        sourceVolume  = "amit-shared-logs"
        containerPath = "/tmp/filebeat-logs"
      }]
      environment = [{
        name  = "LOGSTASH_HOST"
        value = "172.30.100.121"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
            awslogs-group         = "/ecs/filebeat/amit-nginx-filebeat"
            awslogs-region        = "il-central-1"
            awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  volume {
    name = "amit-shared-logs"
  }
}

resource "aws_ecs_service" "nginx_filebeat" {
  name            = "amit-nginx-filebeat-service"
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx_filebeat.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [data.aws_security_group.existing_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_nginx_tg.arn
    container_name   = "nginx"             # <== Must match your container name
    container_port   = 80                  # <== Port that nginx listens on
  }

  depends_on = [aws_lb_listener.nginx_listener]

}


resource "aws_lb_target_group" "ecs_nginx_tg" {
  name     = "amit-nginx-filebeat-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip" # ECS tasks use IP-based target registration

  vpc_id = data.aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = data.aws_lb.imtec_alb.arn
  port              = 8086
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_nginx_tg.arn
  }
}

