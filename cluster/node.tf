data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  cluster_node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority.0.data}' '${aws_eks_cluster.cluster.id}'
USERDATA
}

resource "aws_launch_configuration" "cluster_node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.cluster_node.name}"
  image_id                    = "${data.aws_ami.eks_worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "${aws_eks_cluster.cluster.id}"
  security_groups             = ["${aws_security_group.cluster_node.id}"]
  user_data_base64            = "${base64encode(local.cluster_node_userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster_node" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.cluster_node.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${aws_eks_cluster.cluster.id}"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.cluster.ids}"]

  tag {
    key                 = "Name"
    value               = "${aws_eks_cluster.cluster.id}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${aws_eks_cluster.cluster.id}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "app"
    value               = "${var.app}"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "${local.env}"
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = "${var.team}"
    propagate_at_launch = true
  }

  tag {
    key                 = "contact-email"
    value               = "${var.contact-email}"
    propagate_at_launch = true
  }

  tag {
    key                 = "customer"
    value               = "${var.customer}"
    propagate_at_launch = true
  }
}
