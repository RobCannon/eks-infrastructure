# https://learn.hashicorp.com/terraform/aws/eks-intro
#
# https://www.sentialabs.io/2018/10/21/Integrating-EKS-with-other-AWS-services.html

resource "aws_eks_cluster" "cluster" {
  name     = "${local.cluster_name}"
  role_arn = "${aws_iam_role.cluster_role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids         = ["${data.aws_subnet_ids.cluster.ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy",
  ]
}
