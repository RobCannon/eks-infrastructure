resource "aws_iam_role" "cluster_node" {
  name = "${local.cluster_name}-node"

  assume_role_policy = "${data.aws_iam_policy_document.eks_node_assume_role_policy.json}"
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.cluster_node.name}"
}

resource "aws_iam_role_policy_attachment" "cluster_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.cluster_node.name}"
}

resource "aws_iam_role_policy_attachment" "cluster_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.cluster_node.name}"
}

resource "aws_iam_instance_profile" "cluster_node" {
  name = "${local.cluster_name}"
  role = "${aws_iam_role.cluster_node.name}"
}
