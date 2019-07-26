resource "aws_security_group" "cluster_node" {
  name        = "${local.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${data.aws_vpcs.cluster.ids[0]}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${local.cluster_name}-node",
     "kubernetes.io/cluster/${local.cluster_name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "cluster_node_ingress_self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.cluster_node.id}"
  source_security_group_id = "${aws_security_group.cluster_node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_node_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster_node.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}
