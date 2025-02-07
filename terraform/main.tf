
resource "aws_ecr_repository" "send_mail_repository" {
  name                 = var.service_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "send_mail_repository_lifecycle_policy" {
  repository = aws_ecr_repository.send_mail_repository.id
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only 5 images"
        selection = {
          countType     = "imageCountMoreThan"
          countNumber   = 5
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_lightsail_certificate" "send_mail_certificate" {
  name        = "${var.service_name}-certificare-new6"
  domain_name = "${var.service_name}.vitdo.com"
}

resource "aws_lightsail_container_service" "send_mail_container_service" {
  name        = var.service_name
  power       = "micro"
  scale       = 1
  is_disabled = false

  public_domain_names {
    certificate {
      certificate_name = aws_lightsail_certificate.send_mail_certificate.name
      domain_names     = ["${var.service_name}.vitdo.com"]
    }
  }
  private_registry_access {
    ecr_image_puller_role {
      is_active = true
    }
  }
}

resource "aws_ecr_repository_policy" "send_mail_repository_policy" {
  repository = aws_ecr_repository.send_mail_repository.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowLightsailPull-send-mail",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_lightsail_container_service.send_mail_container_service.private_registry_access[0].ecr_image_puller_role[0].principal_arn
        }
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
      }
    ]
  })

  depends_on = [aws_lightsail_container_service.send_mail_container_service]
}

resource "aws_lightsail_container_service_deployment_version" "send_mail_deployment_version" {
  service_name = aws_lightsail_container_service.send_mail_container_service.name
  container {
    container_name = "${var.service_name}-container"
    image          = var.send_mail_image
    environment = {
      ENV  = "production"
      PORT = "80"
    }
    ports = {
      "443" = "HTTPS"
      "80"  = "HTTP"
      "25"  = "TCP"
    }
  }
  public_endpoint {
    container_name = "${var.service_name}-container"
    container_port = 80

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout_seconds     = 3
      interval_seconds    = 10
      path                = "/health"
      success_codes       = "200-499"
    }
  }
}

