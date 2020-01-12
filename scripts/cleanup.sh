# Set a project to work with
gcloud config set project $GCLOUD_PROJECT_ID

# Delte a repo
curl -u $GIT_USER:$GIT_PASS -X DELETE https://api.github.com/repos/fullmetaltac/jx-demo
curl -u $GIT_USER:$GIT_PASS -X DELETE https://api.github.com/repos/fullmetaltac/environment-jx-kubernetes-production
curl -u $GIT_USER:$GIT_PASS -X DELETE https://api.github.com/repos/fullmetaltac/environment-jx-kubernetes-staging

# Remove a cluster
gcloud container clusters delete jx-kube --zone europe-west1-c --quiet
