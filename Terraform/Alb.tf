#####################################
# AWS Load Balancer Controller IRSA #
#####################################

data "aws_iam_policy_document" "alb_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_irsa" {
  name               = "${var.cluster_name}-alb-irsa"
  assume_role_policy = data.aws_iam_policy_document.alb_assume.json
}

resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_policy_attach" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_irsa.name
}

#####################################
# Kubernetes Service Account (IRSA) #
#####################################

resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_irsa.arn
    }
  }

  depends_on = [
    aws_iam_role.alb_irsa # Ensure role exists before SA
  ]
}

#####################################
# Helm Release: AWS LB Controller   #
#####################################

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    templatefile("${path.root}/alb-values.yaml", {
      vpc_id       = module.vpc.vpc_id
      cluster_name = module.eks.cluster_name
      region       = var.region
    })
  ]

  # Tell Helm to use the pre-created ServiceAccount
  set = [{
    name  = "serviceAccount.create"
    value = "false"
    },

    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.alb_sa.metadata[0].name
  }]

  depends_on = [
    kubernetes_service_account.alb_sa,
    aws_iam_role_policy_attachment.alb_policy_attach # Ensure policy is attached
  ]
}