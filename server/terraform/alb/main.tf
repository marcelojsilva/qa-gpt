variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy the infrastructure in"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The list of public subnet IDs to deploy the ALB in"
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the certificate to use for HTTPS"
}

variable "instance_id" {
  type        = string
  description = "The ID of the EC2 instance to attach to the ALB"
}

resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Allow inbound traffic to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.app_name}-tg"
  target_type = "instance" 
  protocol = "HTTP"
  port     = 8080
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.app_name}-tg"
  }
}

# resource "aws_lb_listener" "front_end" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = 80
#   protocol          = "HTTP"
  
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.main.arn
#   }
# }

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.instance_id
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}
