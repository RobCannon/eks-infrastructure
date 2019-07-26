data "aws_vpcs" "cluster" {
  filter {
    name   = "tag:kubernetes.io/cluster/${local.cluster_name}"
    values = ["shared"]
  }
}

data "aws_subnet_ids" "cluster" {
  vpc_id = "${data.aws_vpcs.cluster.ids[0]}"

  filter {
    name   = "tag:kubernetes.io/cluster/${local.cluster_name}"
    values = ["shared"]
  }
}
