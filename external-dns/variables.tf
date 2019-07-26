variable "app" {
  default = "platform-services"
}

variable "region" {
  default = "us-east-1"
}

variable "team" {
  default = "Developer Services"
}

variable "contact-email" {
  default = "techop-devops@turner.com"
}

variable "customer" {
  default = "Platform Services"
}

locals {
  env = "${terraform.workspace == "default" ? "dev" : terraform.workspace}"

  aws_account = "${terraform.workspace == "prod" ? "aws-platform-services-prod" : "aws-platform-services-dev"}"
  saml_role   = "${local.aws_account}-admin"

  cluster_name = "${local.env == "prod" ? "platform-services-eks-prod" : (local.env == "pst" ? "platform-services-eks-test" : "${var.app}-eks-dev")}"

  tags = {
    app             = "${var.app}"
    env             = "${local.env}"
    team            = "${var.team}"
    "contact-email" = "${var.contact-email}"
    customer        = "${var.customer}"
  }
}
