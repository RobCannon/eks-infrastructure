terraform {
  required_version = "~> 0.11"

  backend "s3" {
    region  = "us-east-1"
    profile = "aws-platform-services-prod:aws-platform-services-prod-admin"
    bucket  = "tf-state-platform-services"
    key     = "eks-infrastructure-external-dns.tfstate"
  }
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "aws" {
  version = "~> 2.8"
  region  = "${var.region}"
  profile = "${local.aws_account}:${local.saml_role}"
}

provider "aws" {
  version = "~> 2.8"
  alias   = "common"
  region  = "us-east-1"
  profile = "aws-platform-services-prod:aws-platform-services-prod-admin"
}

data "aws_eks_cluster" "cluster" {
  name = "${local.cluster_name}"
}

resource "local_file" "kubeconfig" {
  sensitive_content = <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: "${data.aws_eks_cluster.cluster.certificate_authority.0.data}"
    server: "${data.aws_eks_cluster.cluster.endpoint}"
  name: "${data.aws_eks_cluster.cluster.arn}"
contexts:
- context:
    cluster: "${data.aws_eks_cluster.cluster.arn}"
    user: "${data.aws_eks_cluster.cluster.arn}"
  name: "${data.aws_eks_cluster.cluster.arn}"
current-context: "${data.aws_eks_cluster.cluster.arn}"
kind: Config
preferences: {}
users:
- name: "${data.aws_eks_cluster.cluster.arn}"
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - token
      - -i
      - "${data.aws_eks_cluster.cluster.id}"
      command: aws-iam-authenticator
EOF

  filename = "${path.module}/.kube/config"
}

provider "kubernetes" {
  version     = ">= 1.6"
  config_path = "${local_file.kubeconfig.filename}"
}

provider "helm" {
  version         = "~> 0.9"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "tiller"

  kubernetes {
    config_path = "${local_file.kubeconfig.filename}"
  }
}
