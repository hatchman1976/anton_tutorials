data "aws_iam_policy_document" "aws_lbc" {
    statement {
      effect = "Allow"
      principals {
        type = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
      }
      actions = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }
}

# Create the new Load Balancer Role
resource "aws_iam_role" "aws_lbc" {
    name                = "${aws_eks_cluster.eks.name}-aws-lbc"
    assume_role_policy  = data.aws_iam_policy_document.aws_lbc.json
}

# Create the new IAM role policy for the new role
# Note that you can do a JSON encode here as opposed to using a file. This is just another
# way of using abstraction
resource "aws_iam_policy" "aws_lbc" {
    policy  = file("./iam/AWSLoadBalancerController.json")
    name    = "AWSLoadBalancerController"
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "aws_lbc" {
    policy_arn  = aws_iam_policy.aws_lbc.arn
    role        = aws_iam_role.aws_lbc.name
}

# Now associate the new IAM resource to the EKS cluster
resource "aws_eks_pod_identity_association" "aws_lbc" {
    cluster_name        = aws_eks_cluster.eks.name
    namespace           = "kube-system"
    service_account     = "aws-load-balancer-controller"
    role_arn            = aws_iam_role.aws_lbc.arn
}

# Now we need to create the Load Balancer using helm chart and add it to the cluster
resource "helm_release" "aws_lbc" {
    name            = "aws-load-balancer-controller"
    repository      = "https://aws.github.io/eks-charts"
    chart           = "aws-load-balancer-controller"
    namespace       = "kube-system"
    version         = "1.7.2"
  
    set {
        name        = "clusterName"
        value       = aws_eks_cluster.eks.name
    }

    set {
        name        = "serviceAccount.name"
        value       = "aws-load-balancer-controller"
    }

    depends_on = [ helm_release.cluster_autoscaler ]
}