# https://hub.helm.sh/charts/stable/external-dns

# https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/external-dns/setup/

resource "kubernetes_role" "external-dns" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "helm_release" "external-dns" {
  name      = "external-dns"
  chart     = "stable/external-dns"
  version   = "1.7.3"
  namespace = "kube-system"

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "provider"
    value = "aws"
  }
}
