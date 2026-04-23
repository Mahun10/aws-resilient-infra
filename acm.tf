resource "aws_acm_certificate" "app_cert" {
  domain_name       = "www.matteocloudflow.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-acm-cert"
  }
}