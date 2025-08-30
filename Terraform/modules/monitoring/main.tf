# data "aws_eks_cluster" "this" {
#   name = "voting-app-1010"
# }

# data "aws_eks_cluster_auth" "this" {
#   name = data.aws_eks_cluster.this.name
# }

provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority)
    token                  = var.cluster_token
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true

  # values = [
  #   file("${path.module}/values.yaml")
  # ]
}
