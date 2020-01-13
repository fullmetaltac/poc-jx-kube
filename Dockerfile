FROM google/cloud-sdk:latest
WORKDIR /jx

# jx install
RUN apt-get update && apt-get install -y jq
RUN curl -L "https://github.com/jenkins-x/jx/releases/download/$(curl --silent https://api.github.com/repos/jenkins-x/jx/releases/latest | jq -r '.tag_name')/jx-linux-amd64.tar.gz" | tar xzv "jx"
RUN mv jx /usr/local/bin

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh -v v2.13.1

# SSH keys
RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Enviroment
ENV GIT_TEMPLATE_URL=https://github.com/lvthillo/python-flask-docker.git
ENV GIT_TEMPLATE_BRANCH=master
ENV GCLOUD_PROJECT_ID=jx-kube-demo
ENV GIT_MAIL=malkin.dmytro@gmail.com
ENV GIT_NEW_REPO_NAME=jx-demo
ENV JX_ADMIN_PASS=xxx