
resource "aws_lb" "epsilon-lb" {
  name               = "epsilon-lb"
  internal           = false
  load_balancer_type = "network"
  # availability_zone = ["us-east-1a"]
  # subnets = [aws_subnet.epsilon-vpc-pb-1a.aws_subnet.epsilon-vpc-pb-1a.id]
  subnets            = ["${aws_subnet.epsilon-vpc-pb-1a.id}", "${aws_subnet.epsilon-vpc-pb-1b.id}" ]

}
resource "aws_lb_listener" "epsilon-lb" {
  load_balancer_arn = aws_lb.epsilon-lb.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate_validation.sba_react_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.epsilon-tg.arn
  }
}
resource "aws_lb_listener" "epsilon-lb-http" {
  load_balancer_arn = aws_lb.epsilon-lb.arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.epsilon-tg.arn
  }
}

  
resource "aws_lb_target_group" "epsilon-tg" {
  name     = "epsilon-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.epsilon-vpc.id}"
}

resource "aws_lb" "epsilon-lb-api" {
  name               = "epsilon-lb-api"
  internal           = false
  load_balancer_type = "network"
  # availability_zone = ["us-east-1a"]
  # subnets = [aws_subnet.epsilon-vpc-pb-1a.aws_subnet.epsilon-vpc-pb-1a.id]
  subnets            = ["${aws_subnet.epsilon-vpc-pb-1a.id}", "${aws_subnet.epsilon-vpc-pb-1b.id}" ]

}
resource "aws_lb_listener" "epsilon-lb-api" {
  load_balancer_arn = aws_lb.epsilon-lb-api.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate_validation.sba_api2_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.epsilon-tg-api.arn
  }
}

resource "aws_lb_listener" "epsilon-lb-api-http" {
  load_balancer_arn = aws_lb.epsilon-lb-api.arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.epsilon-tg-api.arn
  }
}
resource "aws_lb_target_group" "epsilon-tg-api" {
  name     = "epsilon-tg-api"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.epsilon-vpc.id}"
}


output "App_Endpoint" {
  value = "${aws_lb.epsilon-lb.dns_name}"
}

resource "aws_acm_certificate" "sba_react_cert" {
  domain_name       = "epsilon-smartbankapp.cloudtech-training.com"
  validation_method = "DNS"
}

data "aws_route53_zone" "sba_zone" {
  name         = "cloudtech-training.com"
  private_zone = false
}

resource "aws_route53_record" "sba_react_zone_record" {
  for_each = {
    for dvo in aws_acm_certificate.sba_react_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = false
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.sba_zone.zone_id
}

resource "aws_route53_record" "sba_react_zone_a_record" {
  allow_overwrite = false
  zone_id         = data.aws_route53_zone.sba_zone.zone_id
  name            = "epsilon-smartbankapp.cloudtech-training.com"
  type            = "A"

  alias {
    name                   = aws_lb.epsilon-lb.dns_name
    zone_id                = aws_lb.epsilon-lb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_acm_certificate_validation" "sba_react_cert_validation" {
  certificate_arn         = aws_acm_certificate.sba_react_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.sba_react_zone_record : record.fqdn]
}
# API Certificate
resource "aws_acm_certificate" "sba_api2_cert" {
  domain_name       = "epsilon-smartbankapi.cloudtech-training.com"
  validation_method = "DNS"
}

resource "aws_route53_record" "sba_api2_zone_record" {
  for_each = {
    for dvo in aws_acm_certificate.sba_api2_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = false
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.sba_zone.zone_id
}

resource "aws_route53_record" "sba_api2_zone_a_record" {
  allow_overwrite = false
  zone_id         = data.aws_route53_zone.sba_zone.zone_id
  name            = "epsilon-smartbankapi.cloudtech-training.com"
  type            = "A"

  alias {
    name                   = aws_lb.epsilon-lb-api.dns_name
    zone_id                = aws_lb.epsilon-lb-api.zone_id
    evaluate_target_health = true
  }
}
resource "aws_acm_certificate_validation" "sba_api2_cert_validation" {
  certificate_arn         = aws_acm_certificate.sba_api2_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.sba_api2_zone_record : record.fqdn]
}