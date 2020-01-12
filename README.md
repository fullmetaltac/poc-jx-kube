1) docker build -t jx-demo .
2) docker run -it --name gcloud-config google/cloud-sdk gcloud auth login
3) docker run -it  --volumes-from gcloud-config \
	-v $(pwd)/scripts:/jx \
	-e GIT_USER=git_user \
 	-e GIT_PASS=git_pass \
 	jx-demo bash -c ./create.sh
4) docker run -it  --volumes-from gcloud-config \
        -v $(pwd)/scripts:/jx \
        -e GIT_USER=git_user \
        -e GIT_PASS=git_pass \
        jx-demo bash -c ./cleanup.sh
