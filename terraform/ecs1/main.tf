provider "aws" {
  region = "il-central-1" 
  profile = "default"
}

data "aws_vpc" "imtech_vpc" {
  id = "vpc-042cee0fdc6a5a7e2"  # Replace with your existing VPC ID
}

data "aws_subnet" "private_subnet_1" {
  id = "subnet-088b7d937a4cd5d85"  # Replace with your existing subnet ID
}

data "aws_security_group" "imtech_sg" {
  id = "sg-0ac3749215afde82a"  # Replace with your existing security group ID
}

data "aws_lb" "imtec" {
  name = "imtec"  # Provide the name of the existing ALB
}



data "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id = "rds!db-777ab260-d218-40d6-8bff-a5f247435ce3"
}

locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)
}

data "aws_ssm_parameter" "db_host" {
  name           = "/amit/db/db-host"
  with_decryption = true
}



resource "aws_cloudwatch_log_group" "amit_log_group" {
  name = "/ecs/amit-nginx"  # Log group name
}

resource "aws_lb_target_group" "amit_ecs_tg" {
  name     = "ozai-ecs-tg"
  port     = 3000  # Port on which your containers will be listening
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.imtech_vpc.id

  target_type = "ip"  # This is required for ECS tasks using awsvpc network mode

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_ecs_task_definition" "ecs_nginx" {
  family                    = "nginx-ecs-task"
#   execution_role_arn        = data.aws_iam_role.imtech_role.arn
#   task_role_arn             = data.aws_iam_role.imtech_role.arn # Replace with your task role ARN if different
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  execution_role_arn      = "arn:aws:iam::314525640319:role/ecsTaskExecutionRole"  # Replace with your IAM role ARN


  cpu                        = "256"     # Task-level CPU
  memory                     = "512"     # Task-level Memory

  container_definitions = jsonencode([{
    name      = "amit-nginx"
    image     = "314525640319.dkr.ecr.il-central-1.amazonaws.com/amit/node:latest"
    memory    = 512
    cpu       = 256
    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }
    ]

    environment = [
      {
        name  = "DB_HOST"
        value = data.aws_ssm_parameter.db_host.value
      },
      {
        name  = "DB_USER"
        value = local.rds_credentials["username"]
      },
      {
        name  = "DB_PASS"
        value = local.rds_credentials["password"]
      }
    ]

    logConfiguration: {
      logDriver: "awslogs",
      options: {
        "awslogs-group"         = "/ecs/amit-nginx"  # Correct log group reference
        "awslogs-stream-prefix" = "nginx"  # Prefix for the log stream
        "awslogs-region"        = "il-central-1"  # AWS region
      }
    }
  }])
}

resource "aws_ecs_service" "nginx_ecs_service" {
  name            = "amit-nginx-service"
  cluster         = "imtech" # You don't need to specify a cluster in Fargate
  task_definition = aws_ecs_task_definition.ecs_nginx.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.private_subnet_1.id]
    security_groups  = [data.aws_security_group.imtech_sg.id]
    assign_public_ip = true  # Adjust based on whether you want public IPs
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.amit_ecs_tg.arn
    container_name   = "amit-nginx"
    container_port   = 3000
  }
}

resource "aws_lb_listener" "imtec_listener" {
  load_balancer_arn = data.aws_lb.imtec.arn
  port              = "89"  # ALB listens on port 89
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.amit_ecs_tg.arn  # Forward traffic to target group
  }
}

output "rds_username" {
  value = local.rds_credentials["username"]
  sensitive = true
}

output "db_host" {
  value = data.aws_ssm_parameter.db_host.value
  sensitive = true
}