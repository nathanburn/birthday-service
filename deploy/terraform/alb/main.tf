resource "aws_lb" "main" {
  name               = "${var.name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.name}-alb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.name}-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "120"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.name}-tg-${var.environment}"
    Environment = var.environment
  }
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  #  default_action {
  #    type = "redirect"

  #    redirect {
  #      port        = 443
  #      protocol    = "HTTPS"
  #      status_code = "HTTP_301"
  #    }
  #  }

  # remove if 443 HTTPS re-enabled
  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}

# Redirect traffic to target group
#resource "aws_alb_listener" "https" {
#    load_balancer_arn = aws_lb.main.id
#    port              = 443
#    protocol          = "HTTPS"

#    ssl_policy        = "ELBSecurityPolicy-2016-08"
#    certificate_arn   = var.alb_tls_cert_arn

#    default_action {
#        target_group_arn = aws_alb_target_group.main.id
#        type             = "forward"
#    }
#}

resource "aws_cloudwatch_metric_alarm" "target-500" {
  alarm_name          = "alb-HTTP-5XX"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  # action - SNS email
  alarm_description = "ALB HTTP Code Target 5XX Count"
  alarm_actions     = [aws_sns_topic.alb_alarm.arn]
}

resource "aws_cloudwatch_metric_alarm" "target-response-time" {
  alarm_name          = "alb-Response-Time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  # action - SNS email
  alarm_description = "ALB Target Response Time"
  alarm_actions     = [aws_sns_topic.alb_alarm.arn]
}

# SNS topic to send emails with the Alerts
resource "aws_sns_topic" "alb_alarm" {
  name              = "alb-cloudwatch-alarm-topic"
  kms_master_key_id = aws_kms_key.alb_alarm_sns_encryption_key.id
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
resource "aws_kms_key" "alb_alarm_sns_encryption_key" {
  description             = "ALB alarms sns topic encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

output "aws_alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}
