
data "aws_caller_identity" "current" {}

locals {
  curr_acct_id = data.aws_caller_identity.current.account_id
}


resource "aws_iam_server_certificate" "ssl_cert" {
  count            = var.enable_https ? 1 : 0
  name_prefix      = format("%s-%s-cert-%s", var.name, var.env, local.curr_acct_id)
  certificate_body = file(var.cert_crt_file_path)
  private_key      = file(var.cert_key_file_path)
  # certificate_chain = file(var.cert_chain_file_path)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "application" {
  load_balancer_type               = "application"
  name                             = format("%s-%s-alb", var.name, var.env)
  internal                         = var.alb_is_internal
  security_groups                  = var.security_groups
  subnets                          = var.subnets
  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type
  tags                             = merge(var.tags, {"Name" = format("%s-%s-alb", var.name, var.env)})

  # access_logs {
  #   enabled = true
  #   bucket  = "${var.log_bucket_name}"
  #   prefix  = "${var.log_location_prefix}"
  # }
}


resource "aws_lb_target_group" "web_target_group" {
  name                 = lookup(var.web_http_target_group, "name")
  vpc_id               = var.vpc_id
  port                 = lookup(var.web_http_target_group, "backend_port")
  protocol             = upper(lookup(var.web_http_target_group, "backend_protocol"))
  deregistration_delay = lookup(var.web_http_target_group, "deregistration_delay", lookup(var.target_group_defaults, "deregistration_delay"))
  target_type          = lookup(var.web_http_target_group, "target_type", lookup(var.target_group_defaults, "target_type"))
  slow_start           = lookup(var.web_http_target_group, "slow_start", lookup(var.target_group_defaults, "slow_start"))

  health_check {
    interval            = lookup(var.web_http_target_group, "health_check_interval", lookup(var.target_group_defaults, "health_check_interval"))
    path                = lookup(var.web_http_target_group, "health_check_path", lookup(var.target_group_defaults, "health_check_path"))
    port                = lookup(var.web_http_target_group, "health_check_port", lookup(var.target_group_defaults, "health_check_port"))
    healthy_threshold   = lookup(var.web_http_target_group, "health_check_healthy_threshold", lookup(var.target_group_defaults, "health_check_healthy_threshold"))
    unhealthy_threshold = lookup(var.web_http_target_group, "health_check_unhealthy_threshold", lookup(var.target_group_defaults, "health_check_unhealthy_threshold"))
    timeout             = lookup(var.web_http_target_group, "health_check_timeout", lookup(var.target_group_defaults, "health_check_timeout"))
    protocol            = upper(lookup(var.web_http_target_group, "healthcheck_protocol", lookup(var.web_http_target_group, "backend_protocol")))
    matcher             = lookup(var.web_http_target_group, "health_check_matcher", lookup(var.target_group_defaults, "health_check_matcher"))
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = lookup(var.web_http_target_group, "cookie_duration", lookup(var.target_group_defaults, "cookie_duration"))
    enabled         = lookup(var.web_http_target_group, "stickiness_enabled", lookup(var.target_group_defaults, "stickiness_enabled"))
  }

  tags       = merge(var.tags, {"Name" = lookup(var.web_http_target_group, "name")})
  depends_on = [aws_lb.application]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name                 = lookup(var.app_http_target_group, "name")
  vpc_id               = var.vpc_id
  port                 = lookup(var.app_http_target_group, "backend_port")
  protocol             = upper(lookup(var.app_http_target_group, "backend_protocol"))
  deregistration_delay = lookup(var.app_http_target_group, "deregistration_delay", lookup(var.target_group_defaults, "deregistration_delay"))
  target_type          = lookup(var.app_http_target_group, "target_type", lookup(var.target_group_defaults, "target_type"))
  slow_start           = lookup(var.app_http_target_group, "slow_start", lookup(var.target_group_defaults, "slow_start"))

  health_check {
    interval            = lookup(var.app_http_target_group, "health_check_interval", lookup(var.target_group_defaults, "health_check_interval"))
    path                = lookup(var.app_http_target_group, "health_check_path", lookup(var.target_group_defaults, "health_check_path"))
    port                = lookup(var.app_http_target_group, "health_check_port", lookup(var.target_group_defaults, "health_check_port"))
    healthy_threshold   = lookup(var.app_http_target_group, "health_check_healthy_threshold", lookup(var.target_group_defaults, "health_check_healthy_threshold"))
    unhealthy_threshold = lookup(var.app_http_target_group, "health_check_unhealthy_threshold", lookup(var.target_group_defaults, "health_check_unhealthy_threshold"))
    timeout             = lookup(var.app_http_target_group, "health_check_timeout", lookup(var.target_group_defaults, "health_check_timeout"))
    protocol            = upper(lookup(var.app_http_target_group, "healthcheck_protocol", lookup(var.app_http_target_group, "backend_protocol")))
    matcher             = lookup(var.app_http_target_group, "health_check_matcher", lookup(var.target_group_defaults, "health_check_matcher"))
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = lookup(var.app_http_target_group, "cookie_duration", lookup(var.target_group_defaults, "cookie_duration"))
    enabled         = lookup(var.app_http_target_group, "stickiness_enabled", lookup(var.target_group_defaults, "stickiness_enabled"))
  }

  tags       = merge(var.tags, {"Name" = lookup(var.app_http_target_group, "name")})
  depends_on = [aws_lb.application]

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_lb_target_group" "web_https_target_group" {
#  count                = var.enable_https ? 1 : 0
#  name                 = lookup(var.web_https_target_group, "name")
#  vpc_id               = var.vpc_id
#  port                 = lookup(var.web_https_target_group, "backend_port")
#  protocol             = upper(lookup(var.web_https_target_group, "backend_protocol"))
#  deregistration_delay = lookup(var.web_https_target_group, "deregistration_delay", lookup(var.target_group_defaults, "deregistration_delay"))
#  target_type          = lookup(var.web_https_target_group, "target_type", lookup(var.target_group_defaults, "target_type"))
#  slow_start           = lookup(var.web_https_target_group, "slow_start", lookup(var.target_group_defaults, "slow_start"))
#
#  health_check {
#    interval            = lookup(var.web_https_target_group, "health_check_interval", lookup(var.target_group_defaults, "health_check_interval"))
#    path                = lookup(var.web_https_target_group, "health_check_path", lookup(var.target_group_defaults, "health_check_path"))
#    port                = lookup(var.web_https_target_group, "health_check_port", lookup(var.target_group_defaults, "health_check_port"))
#    healthy_threshold   = lookup(var.web_https_target_group, "health_check_healthy_threshold", lookup(var.target_group_defaults, "health_check_healthy_threshold"))
#    unhealthy_threshold = lookup(var.web_https_target_group, "health_check_unhealthy_threshold", lookup(var.target_group_defaults, "health_check_unhealthy_threshold"))
#    timeout             = lookup(var.web_https_target_group, "health_check_timeout", lookup(var.target_group_defaults, "health_check_timeout"))
#    protocol            = upper(lookup(var.web_https_target_group, "healthcheck_protocol", lookup(var.web_https_target_group, "backend_protocol")))
#    matcher             = lookup(var.web_https_target_group, "health_check_matcher", lookup(var.target_group_defaults, "health_check_matcher"))
#  }
#
#  stickiness {
#    type            = "lb_cookie"
#    cookie_duration = lookup(var.web_https_target_group, "cookie_duration", lookup(var.target_group_defaults, "cookie_duration"))
#    enabled         = lookup(var.web_https_target_group, "stickiness_enabled", lookup(var.target_group_defaults, "stickiness_enabled"))
#  }
#
#  tags       = merge(var.tags, {"Name" = lookup(var.web_https_target_group, "name")})
#  depends_on = [aws_lb.application]
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
# resource "aws_lb_target_group" "app_https_target_group" {
#  count                = var.enable_https ? 1 : 0
#  name                 = lookup(var.app_https_target_group, "name")
#  vpc_id               = var.vpc_id
#  port                 = lookup(var.app_https_target_group, "backend_port")
#  protocol             = upper(lookup(var.app_https_target_group, "backend_protocol"))
#  deregistration_delay = lookup(var.app_https_target_group, "deregistration_delay", lookup(var.target_group_defaults, "deregistration_delay"))
#  target_type          = lookup(var.app_https_target_group, "target_type", lookup(var.target_group_defaults, "target_type"))
#  slow_start           = lookup(var.app_https_target_group, "slow_start", lookup(var.target_group_defaults, "slow_start"))
#
#  health_check {
#    interval            = lookup(var.app_https_target_group, "health_check_interval", lookup(var.target_group_defaults, "health_check_interval"))
#    path                = lookup(var.app_https_target_group, "health_check_path", lookup(var.target_group_defaults, "health_check_path"))
#    port                = lookup(var.app_https_target_group, "health_check_port", lookup(var.target_group_defaults, "health_check_port"))
#    healthy_threshold   = lookup(var.app_https_target_group, "health_check_healthy_threshold", lookup(var.target_group_defaults, "health_check_healthy_threshold"))
#    unhealthy_threshold = lookup(var.app_https_target_group, "health_check_unhealthy_threshold", lookup(var.target_group_defaults, "health_check_unhealthy_threshold"))
#    timeout             = lookup(var.app_https_target_group, "health_check_timeout", lookup(var.target_group_defaults, "health_check_timeout"))
#    protocol            = upper(lookup(var.app_https_target_group, "healthcheck_protocol", lookup(var.app_https_target_group, "backend_protocol")))
#    matcher             = lookup(var.app_https_target_group, "health_check_matcher", lookup(var.target_group_defaults, "health_check_matcher"))
#  }
#
#  stickiness {
#    type            = "lb_cookie"
#    cookie_duration = lookup(var.app_https_target_group, "cookie_duration", lookup(var.target_group_defaults, "cookie_duration"))
#    enabled         = lookup(var.app_https_target_group, "stickiness_enabled", lookup(var.target_group_defaults, "stickiness_enabled"))
#  }
#
#  tags       = merge(var.tags, {"Name" = lookup(var.app_https_target_group, "name")})
#  depends_on = [aws_lb.application]
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}

resource "aws_lb_target_group_attachment" "web_http_target_attachment" {
  count   = length(var.web_target_ids)
  target_group_arn  = aws_lb_target_group.web_target_group.arn
  target_id         = element(var.web_target_ids, count.index)
}

resource "aws_lb_target_group_attachment" "app_http_target_attachment" {
  count   = length(var.app_target_ids)
  target_group_arn  = aws_lb_target_group.app_target_group.arn
  target_id         = element(var.app_target_ids, count.index)
}

#resource "aws_lb_target_group_attachment" "web_https_target_attachment" {
#  count   = var.enable_https ? length(var.web_target_ids) : 0
#  target_group_arn  = aws_lb_target_group.web_http_target_group[0].arn
#  target_id         = element(var.web_target_ids, count.index)
#}

#resource "aws_lb_target_group_attachment" "app_https_target_attachment" {
#  count   = var.enable_https ? length(var.app_target_ids) : 0
#  target_group_arn  = aws_lb_target_group.app_http_target_group[0].arn
#  target_id         = element(var.app_target_ids, count.index)
#}



resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.application.arn
  port              = lookup(var.http_tcp_listeners[count.index], "port")
  protocol          = lookup(var.http_tcp_listeners[count.index], "protocol")
  count             = length(var.http_tcp_listeners)

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.id
    type             = "redirect"
    redirect {
      host           = "#{host}"
      path           = "/#{path}"
      port           = "443"
      protocol       = "HTTPS"
      query          = "#{query}"
      status_code    = "HTTP_301"
    }
}
}

resource "aws_lb_listener" "frontend_https" {
  count             = var.enable_https ? length(var.https_listeners) : 0
  load_balancer_arn = aws_lb.application.arn
  port              = lookup(var.https_listeners[count.index], "port")
  protocol          = lookup(var.https_listeners[count.index], "protocol")
  certificate_arn   = aws_iam_server_certificate.ssl_cert[0].arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = aws_lb_target_group.web_target_group.id
    type             = "forward"
  }
}


#resource "aws_lb_listener_rule" "app_rule" {
#  listener_arn = aws_lb_listener.frontend_http[0].arn
#  priority     = 1
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.app_target_group.id
#  }
#
#  condition {
#    path_pattern {
#      values = ["/bigfishserver/*"]
#    }
#  }
#}

#resource "aws_lb_listener_rule" "web_rule" {
#  listener_arn = aws_lb_listener.frontend_http[0].arn
#  priority     = 2
#
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.web_target_group.id
#  }
#
#  condition {
#    path_pattern {
#      values = ["/"]
#    }
#  }
#}


resource "aws_lb_listener_rule" "app_https_rule" {
  listener_arn = aws_lb_listener.frontend_https[0].arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.id
  }

  condition {
    path_pattern {
      values = ["/bigfishserver/*"]
    }
  }
}

resource "aws_lb_listener_rule" "web_https_rule" {
  listener_arn = aws_lb_listener.frontend_https[0].arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.id
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

