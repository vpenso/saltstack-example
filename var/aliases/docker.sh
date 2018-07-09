DOCKER_LOCAL_REGISTRY='lxcm01:5000'

export DOCKER_LOCAL_REGISTRY

echo DOCKER_LOCAL_REGISTRY=$DOCKER_LOCAL_REGISTRY

# echo 'docker-list-local-repository-catalog() -- List repositories in local registry'
docker-list-local-repository-catalog() {
        curl -s -X GET http://$DOCKER_LOCAL_REGISTRY/v2/_catalog | jq '.'
}

echo 'docker-list-local-repository-tags() -- List local repository tags'
docker-list-local-repository-tags() {
        curl -s -X GET http://$DOCKER_LOCAL_REGISTRY/v2/$1/tags/list | jq '.'
}

echo 'docker-build-salt-master() -- Build the salt-master container image'
docker-build-salt-master() {
        docker build -t salt-master $SALT_DOCKER_PATH/var/dockerfiles/salt-master/
}

echo 'docker-run-salt-master() -- Run salt-master service container'
docker-run-salt-master() {
        echo Start salt-master container...
        docker run --detach \
                   --name salt-master \
                   --publish 4505:4505 \
                   --publish 4506:4506 \
                   --volume $SALT_STATE_TREE/:/srv/salt \
                   salt-master
} 

echo 'docker-attach-salt-master() -- Attach to the salt-master daemon console'
docker-attach-salt-master() {
        echo Detach with ctrl-p ctrl-q
        docker attach salt-master
}

echo 'docker-container-remove-all() -- Stop & remove all containers on localhost'
docker-container-remove-all() {
        docker container stop $(docker ps -a -q)
        docker container prune -f
}
