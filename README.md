# Send Mail Service

## Description

This project aims to configure a Sendmail server on AWS to support multiple domains, enabling email functionality for two additional Java applications running on Tomcat. The existing setup uses ActiveMQ and Sendmail on an Amazon EC2 instance for email delivery, but it currently handles only one domain.

The objectives of this project include:
- Expanding Sendmail to support multiple domains.
- Ensuring proper email deliverability through SPF, DKIM, and DMARC configuration.
- Reducing dependency on third-party email services, lowering operational costs.
- Integrating and verifying the email setup with ActiveMQ.
- Fixing and setting up a small Java application, along with unit tests, to monitor email system health.

## Installation

### Login to AWS

Authenticate Docker with AWS Elastic Container Registry (ECR):

```sh
aws ecr get-login-password --region eu-north-1 --profile my | \
docker login --username AWS --password-stdin 614676590171.dkr.ecr.eu-north-1.amazonaws.com
```

### Push Docker Image to Registry

Build and push the Docker image to AWS Lightsail:

```sh
export SEND_MAIL_VERSION=1.0.7 && \
docker buildx build -t send-mail:${SEND_MAIL_VERSION} --platform linux/amd64 . && \
aws lightsail push-container-image --region eu-north-1 --service-name send-mail --label send-mail --image send-mail:${SEND_MAIL_VERSION} --profile my
```

### Update Terraform Configuration

Modify `./terraform/terraform.tfvars` with the new `send_mail_image` version and apply the changes:

```sh
AWS_PROFILE=my terraform -chdir=./terraform apply
```

## Testing

### Send an Email

To test email sending via Sendmail:

```sh
echo "{text}" | sendmail -f {from_address} -v {to_address}
```

Ensure that ActiveMQ and Sendmail are functioning correctly and that emails are being delivered properly.

