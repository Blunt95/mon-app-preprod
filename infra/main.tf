terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "preprod" {
  name = "preprod-cluster-tf"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "mon-app-preprod-tf"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::606604313843:role/LabRole"

  container_definitions = jsonencode([{
    name  = "mon-app"
    image = "606604313843.dkr.ecr.us-east-1.amazonaws.com/mon-app:latest"
    portMappings = [{ containerPort = 3000 }]
    essential = true
  }])
}

resource "aws_ecs_service" "app" {
  name            = "mon-app-service-tf"
  cluster         = aws_ecs_cluster.preprod.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0e4e180cc7376f723"]
    assign_public_ip = true
  }
}
