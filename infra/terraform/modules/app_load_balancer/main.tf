resource "aws_alb" "main" {
  name            = "${var.application_name}-lb"
  subnets         = var.subnets
  security_groups = var.load_balancer_sg
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

resource "aws_alb_target_group" "app" {
  name        = "${var.application_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold = "3"
    interval          = "30"
    protocol          = "HTTP"
    matcher           = "200"
    timeout           = "3"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_alb_target_group.app.arn
  port      = 80
  count     = length(var.web_servers_info)
  target_id = var.web_servers_info[count.index].id
}