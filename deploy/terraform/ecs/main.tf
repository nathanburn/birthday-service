resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dynamodb" {
  name        = "${var.name}-task-policy-dynamodb"
  description = "Policy that allows access to DynamoDB"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:UpdateTimeToLive",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:ListTables",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:UpdateTable"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "secrets" {
  name        = "${var.name}-task-policy-secrets"
  description = "Policy that allows access to the secrets we created"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AccessSecrets",
            "Effect": "Allow",
            "Action": [
              "secretsmanager:GetSecretValue"
            ],
            "Resource": ${jsonencode(var.container_secrets_arns)}
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment-for-secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name}-task-${var.environment}"

  tags = {
    Name        = "${var.name}-task-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = "${var.name}-container-${var.environment}"
    image       = "${var.container_image}:latest"
    essential   = true
    environment = var.container_environment
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
    secrets = var.container_secrets
  }])

  tags = {
    Name        = "${var.name}-task-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster-${var.environment}"
  tags = {
    Name        = "${var.name}-cluster-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "main" {
  name                               = "${var.name}-service-${var.environment}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = var.ecs_service_security_groups
    subnets          = var.subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group_arn
    container_name   = "${var.name}-container-${var.environment}"
    container_port   = var.container_port
  }

  # we ignore task_definition changes as the revision changes on deploy
  # of a new version of the application
  # desired_count is ignored as it can change due to autoscaling policy
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  # self-healing by "aws_appautoscaling_policy" "ecs_policy_cpu"

  # action - SNS email
  alarm_description = "ECS CPU Utilization Greater Than Threshold"
  alarm_actions     = [aws_sns_topic.ecs_alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  # self-healing by "aws_appautoscaling_policy" "ecs_policy_cpu"

  # action - SNS email
  alarm_description = "ECS CPU Utilization Less Than Threshold"
  alarm_actions     = [aws_sns_topic.ecs_alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "cb_memory_utilization_high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  # self-healing by "aws_appautoscaling_policy" "ecs_policy_memory"

  # action - SNS email
  alarm_description = "ECS Memory Utilization Greater Than Threshold"
  alarm_actions     = [aws_sns_topic.ecs_alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_low" {
  alarm_name          = "cb_memory_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  # self-healing by "aws_appautoscaling_policy" "ecs_policy_memory"

  # action - SNS email
  alarm_description = "ECS Memory Utilization Less Than Threshold"
  alarm_actions     = [aws_sns_topic.ecs_alarm.arn]
}

# SNS topic to send emails with the Alerts
resource "aws_sns_topic" "ecs_alarm" {
  name              = "ecs-cloudwatch-alarm-topic"
  kms_master_key_id = aws_kms_key.ecs_alarm_sns_encryption_key.id
  delivery_policy   = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
  ## This local exec, suscribes your email to the topic 
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alerts_email} --region ${var.region}"
  }
}

## KMS Key to encrypt the SNS topic - security best practise
resource "aws_kms_key" "ecs_alarm_sns_encryption_key" {
  description             = "ECS alarms sns topic encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}
