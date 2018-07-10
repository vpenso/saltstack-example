DOCKER_LOCAL_REGISTRY='lxcm01:5000'

export DOCKER_LOCAL_REGISTRY

docker-list-local-repository-catalog() {

        curl -s -X GET http://$DOCKER_LOCAL_REGISTRY/v2/_catalog | jq '.'

}

docker-list-local-repository-tags() {

        curl -s -X GET http://$DOCKER_LOCAL_REGISTRY/v2/$1/tags/list | jq '.'

}

docker-build-salt-master() {

        docker build -t salt-master $SALT_DOCKER_PATH/var/dockerfiles/salt-master/

}

docker-run-salt-master() {

        echo Start salt-master container...
        docker run --detach \
                   --name salt-master \
                   --publish 4505:4505 \
                   --publish 4506:4506 \
                   --volume $SALT_STATE_TREE/:/srv/salt \
               salt-master

} 

docker-attach-salt-master() {

        echo Detach with ctrl-p ctrl-q
        docker attach salt-master

}

docker-container-remove-all() {

        docker container stop $(docker ps -a -q)
        docker container prune -f

}
