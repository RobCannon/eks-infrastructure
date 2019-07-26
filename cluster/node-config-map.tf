resource "local_file" "config-map-aws-auth" {
  sensitive_content = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.cluster_node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF

  filename = "${path.module}/.kube/config-map-aws-auth.yaml"
}

resource "null_resource" "config-map-aws-auth" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_arn = "${aws_eks_cluster.cluster.arn}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.config-map-aws-auth.filename} --kubeconfig ${local_file.kubeconfig.filename}"
  }
}
