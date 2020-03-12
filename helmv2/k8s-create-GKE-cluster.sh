sudo apt-get install tree
gcloud config set project smulkutk-project-1
gcloud config set compute/zone us-west1-a
gcloud container clusters create k8s-cluster --num-nodes=3
gcloud container clusters get-credentials k8s-cluster
sleep 10
KUBE_EDITOR="vim"
echo $KUBE_EDITOR
echo "### ### Get credentials ### ###"
gcloud container clusters get-credentials k8s-cluster
echo ""
echo "### ### GKE nodes ### ### "
kubectl get nodes -o wide
echo ""
echo "### ### confirm cluster is running ### ### "
gcloud container clusters list
echo ""
kubectl get pods -o wide
echo ""
