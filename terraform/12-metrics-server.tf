# The whole point of creating a metrics server is so that the cluster management 
# has a single place to draw on all the metrics being produced by the nodes in
# the cluster so that it can take actions if they cross thresholds

resource "helm_release" "metrics_server" {
  
    name = "metrics-server"

    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    chart = "metrics-server"
    namespace = "kube-system"
    version = "3.12.1"

    # This refers to a file that we explicitly need to create in order
    # to override or create variables for the metric server
    values = [file("${path.module}/values/metrics-server.yaml")]

    depends_on = [ aws_eks_node_group.general ]
}