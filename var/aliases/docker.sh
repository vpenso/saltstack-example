echo 'docker-search-repository-tags()  -- list tags from a repository on DockerHub'
docker-search-repository-tags() {
        local url="https://registry.hub.docker.com/v2/repositories/library/$1/tags/"
        curl -s -S "$url" | \
                jq '."results"[]["name"]' | \
                tr -d '"' | \
                sort -r
}

echo 'docker-build-salt-master() -- Build the salt-master container image'
docker-build-salt-master() {
        docker build -t salt-master $SALT_DOCKER_PATH/var/dockerfiles/salt-master/
}

echo 'docker-run-salt-master() -- Run the salt-master container with a shell'
docker-run-salt-master() {
        echo Start salt-master container...
        docker run --detach \
                   --name salt-master \
                   --publish 4505:4505 \
                   --publish 4506:4506 \
                   --volume $SALT_DOCKER_PATH/srv/salt:/srv/salt \
                   salt-master
} 

echo 'docker-attach-salt-master() -- Attach to the salt-master daemon console'
docker-attach-salt-master() {
        echo Detach with ctrl-p ctrl-q
        docker attach salt-master
}
