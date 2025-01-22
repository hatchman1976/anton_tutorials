resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name = "eks-pod-identity-agent"
  
  # to find the latest version run "aws eks describe-addon-versions --region us-west-2 --addon-name eks-pod-identity-agent"
  addon_version = "v1.3.4-eksbuild.1"
}