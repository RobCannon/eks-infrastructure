data "aws_iam_role" "cluster_node" {
  name = "${local.cluster_name}-node"
}

data "aws_route53_zone" "hosted-zone" {
  provider = "aws.common"
  name     = "turner-systems.com."
}

data "aws_iam_policy_document" "external-dns" {
  statement {
    actions = ["route53:ChangeResourceRecordSets"]

    resources = [
      "arn:aws:route53:::hostedzone/${data.aws_route53_zone.hosted-zone.zone_id}",
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "external-dns" {
  name        = "${local.cluster_name}-external-dns"
  description = "Policy to change DNS records for external-dns"

  policy = "${data.aws_iam_policy_document.external-dns.json}"
}

resource "aws_iam_role_policy_attachment" "cluster_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${aws_iam_policy.external-dns.arn}"
  role       = "${data.aws_iam_role.cluster_node.name}"
}
