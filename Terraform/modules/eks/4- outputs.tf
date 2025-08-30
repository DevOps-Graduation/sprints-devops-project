output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_name" {
  value = aws_eks_node_group.this.node_group_name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}
output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.eks.url
}

# output "cluster_token" {
#   value = aws_eks_cluster.this.token
# }
