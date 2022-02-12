# --- dns/main.tf ---

data "aws_route53_delegation_set" "dset" {
  id = var.delegation_set_id
}

resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = var.common_tags
  delegation_set_id = data.aws_route53_delegation_set.dset.id
}

resource "aws_route53_record" "root-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.root_domain_name
    zone_id                = var.root_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.www_domain_name
    zone_id                = var.www_hosted_zone_id
    evaluate_target_health = false
  }
}