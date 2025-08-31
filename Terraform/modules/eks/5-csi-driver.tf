locals {
  cluster_name = aws_eks_cluster.this.name
  cluster_oidc = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# OIDC provider for IRSA
resource "aws_iam_openid_connect_provider" "eks" {
  url            = local.cluster_oidc
  client_id_list = ["sts.amazonaws.com"]
}

# IAM Role for EBS CSI Driver (using IRSA)
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${local.cluster_name}-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(local.cluster_oidc, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attach AWS managed policy for EBS CSI
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# Wait for node group to be ready before creating addon
resource "null_resource" "wait_for_nodes" {
  depends_on = [aws_eks_node_group.this]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EKS nodes to be Ready..."
      kubectl wait --for=condition=Ready nodes --all --timeout=15m
    EOT
  }
}

# Install the EBS CSI driver as an addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = local.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.48.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_attach,
    null_resource.wait_for_nodes
  ]
}
