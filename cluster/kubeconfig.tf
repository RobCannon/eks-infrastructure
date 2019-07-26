resource "local_file" "kubeconfig" {
  sensitive_content = <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: "${aws_eks_cluster.cluster.certificate_authority.0.data}"
    server: "${aws_eks_cluster.cluster.endpoint}"
  name: "${aws_eks_cluster.cluster.arn}"
contexts:
- context:
    cluster: "${aws_eks_cluster.cluster.arn}"
    user: "${aws_eks_cluster.cluster.arn}"
  name: "${aws_eks_cluster.cluster.arn}"
current-context: "${aws_eks_cluster.cluster.arn}"
kind: Config
preferences: {}
users:
- name: "${aws_eks_cluster.cluster.arn}"
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - token
      - -i
      - "${aws_eks_cluster.cluster.id}"
      command: aws-iam-authenticator
EOF

  filename = "${path.module}/.kube/config"
}

provider "kubernetes" {
  version     = ">= 1.6"
  config_path = "${local_file.kubeconfig.filename}"
}
