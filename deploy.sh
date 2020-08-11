#!/usr/bin/env bash

set -euo pipefail

LOCATION="us-central1"
REPO="gcr.io/$PROJECT_ID/demo-app"
HOSTNAME=${1:-"demo-app.ahalab.dev"}

function check_file_exists() {
  if [[ ! -f $1 ]]; then
    echo "$2"
    exit 1
  fi
}

function require_program() {
  if ! [[ -x "$(command -v "$1")" ]]; then
    echo "error: $1 is not installed" >&2
    exit 1
  fi
}

for program in "git" "gcloud" "docker" "jq" "make"; do
  require_program "$program"
done

check_file_exists \
  "$HOME/.config/gcloud/access_tokens.db" \
  "GCP credentials not found. Did you run gcloud auth login?"

check_file_exists \
  "$HOME/.config/gcloud/application_default_credentials.json" \
  "GCP Application Default Credentials not found. Did you run gcloud auth application-default login?"

check_file_exists "$HOME/.docker/config.json" "No Docker config found, did you run gcloud auth configure-docker?"

GCR_CRED_HELPER=$(jq -r '.credHelpers."gcr.io"' < "$HOME/.docker/config.json")

if [[ "$GCR_CRED_HELPER" != "gcloud" ]]; then
  echo "GCloud isn't set as the credential helper for GCR, did you run gcloud auth configure-docker?"
  exit 1
fi

echo "Standing up infrastructure in project '$PROJECT_ID', it may take up to 10 minutes to create the cluster"
make tf-apply

VERSION=$(git rev-parse --short HEAD)
echo "Building and pushing Docker image with tags $VERSION and latest"
docker build -t "$REPO":"$VERSION" -t "$REPO":latest .
docker push "$REPO":"$VERSION"
docker push "$REPO":latest

echo "Fetching Kubernetes credentials"
gcloud container clusters get-credentials demo-app --region "$LOCATION" --project "$PROJECT_ID"

echo "Fetching Helm chart dependencies"
docker run \
    -it \
    --rm \
    -w /usr/src/manifests \
    -v "$(pwd)/manifests:/usr/src/manifests" \
    alpine/helm:3.2.4 dep up demo-app

echo "Deploying app"
docker run \
    -it \
    --rm \
    -w /usr/src/manifests \
    -v "$(pwd)/manifests:/usr/src/manifests" \
    alpine/helm:3.2.4 template \
      --release-name demo-app \
      --set-string image.repository="$REPO" \
      --set-string image.tag="$VERSION" \
      --set-string ingress.hostname="$HOSTNAME" \
      demo-app | kubectl apply -f -

echo "Waiting for deploy to finish"
kubectl -n demo-app rollout status deploy demo-app

LOAD_BALANCER_IP=$(kubectl get service demo-app-ingress-nginx-controller -o json | jq -r '.status.loadBalancer.ingress[0].ip')
echo "Deployment finished. External load balancer ip: $LOAD_BALANCER_IP"
echo "Note: if you set a hostname, this is what you'll set on the DNS record."
echo "Otherwise you can ignore this."

echo "Application deployed, watch the post-deployment tests:"
kubectl -n demo-app logs -f demo-app-test
