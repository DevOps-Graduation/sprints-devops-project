data "aws_eks_cluster" "this" {
  name = "voting-app-sarah"
}

data "aws_eks_cluster_auth" "this" {
  name = data.aws_eks_cluster.this.name
}


provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
