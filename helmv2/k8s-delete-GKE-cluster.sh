echo ""
gcloud config set project smulkutk-project-1
gcloud config set compute/zone us-west1-a

### Delete cluster -
gcloud container clusters delete k8s-cluster -z us-west1-a -q
echo ""