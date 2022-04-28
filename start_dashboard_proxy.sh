aws eks update-kubeconfig --name refarch-dev-sl-k8s-cluster --region us-east-1
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
kubectl proxy
