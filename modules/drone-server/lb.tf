resource "aws_lb" "ci" {
  name            = "drone-server-lb"
  security_groups = [aws_security_group.lb.id]
  subnets         = var.public_subnets
  tags = {
    Name = var.fqdn
  }
}

resource "aws_lb_listener" "ci_end" {
  load_balancer_arn = aws_lb.ci.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.ci_server.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "ci_server" {
  name        = "ci-server-ecs"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    matcher             = "200"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
  }
}

resource "aws_route53_record" "ci_public_url" {
  zone_id = var.root_domain_zone_id
  name    = var.fqdn
  type    = "A"

  alias {
    name                   = aws_lb.ci.dns_name
    zone_id                = aws_lb.ci.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.fqdn
  validation_method = "DNS"
  tags = {
    Name = var.fqdn
  }
  provider = aws
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  provider        = aws

  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn,
  ]
}

resource "aws_route53_record" "cert_validation" {
  name       = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
  type       = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
  zone_id    = var.root_domain_zone_id
  records    = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
  ttl        = 300
  depends_on = [aws_acm_certificate.cert]
}

resource "aws_security_group" "lb" {
  description = "Traffic from web to Drone Server"
  name        = "ci-server-lb-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.ip_access_whitelist
  }
}
