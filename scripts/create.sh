# Set project to work with
gcloud config set project $GCLOUD_PROJECT_ID

# Git init conf
git config --global user.name $GIT_USER
git config --global user.email $GIT_MAIL


#Add ssh key to github
SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
curl -u $GIT_USER:$GIT_PASS -d '{ "title": "'"$GIT_NEW_REPO_NAME"'", "key": "'"$SSH_KEY"'" }' -H "Content-Type: application/json" -X POST https://api.github.com/user/keys

# Generate a token
GIT_TOKEN=$(curl -u $GIT_USER:$GIT_PASS -d '{ "scopes": [ "repo", "read:user", "read:org", "user:email", "write:repo_hook", "delete_repo" ], "note": "jx-token" }' -H "Content-Type: application/json" -X POST https://api.github.com/authorizations | jq -r .token)

# Create a new repo
GIT_REPO_URL=$(curl -u $GIT_USER:$GIT_PASS -d '{"name": "'"$GIT_NEW_REPO_NAME"'", "auto_init" : false}' -H "Content-Type: application/json" -X POST https://api.github.com/user/repos | jq -r .clone_url)

# Fill new repo from template
git clone $GIT_TEMPLATE_URL jx-demo
git -C jx-demo checkout $GIT_TEMPLATE_BRANCH
rm -rf jx-demo/.git 
git -C jx-demo init
git -C jx-demo add --all
git -C jx-demo commit -m "project clone"
git -C jx-demo remote add origin git@github.com:${GIT_USER}/${GIT_NEW_REPO_NAME}.git
git -C jx-demo push -u origin master

# Create a cluster
jx create cluster gke -b --skip-login \
    --default-admin-password=$JX_ADMIN_PASS \
    -n jx-kube \
    -p $GCLOUD_PROJECT_ID \
    -z europe-west1-c \
    --install-dependencies \
    --prow=false \
    --git-api-token=$GIT_TOKEN \
    --static-jenkins \
    --git-username=$GIT_USER \
    --environment-git-owner=$GIT_USER \
    --git-provider-url=https://github.com 


# Import a project to jx
jx import ./jx-demo --git-username=$GIT_USER --git-api-token=$GIT_TOKEN


# Create changes in new branch
git -C jx-demo checkout -b new_branch
echo ' ' >> jx-demo/README.md
git -C jx-demo add --all
git -C jx-demo commit -m "build trigger"
git -C jx-demo push -u origin new_branch

# Create and merge PR
curl -u $GIT_USER:$GIT_PASS -d '{ "title": "trigger", "body": "trigger", "head": "new_branch", "base": "master" }' -H "Content-Type: application/json" -X POST https://api.github.com/repos/${GIT_USER}/${GIT_NEW_REPO_NAME}/pulls
curl -u $GIT_USER:$GIT_PASS -X PUT https://api.github.com/repos/fullmetaltac/jx-demo/pulls/1/merge

echo "Run 'jx get applications' after Jenkins build finish"
