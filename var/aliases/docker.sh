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

echo 'docker-run-prometheus() -- Run Prometheus service container'
docker-run-prometheus() {
        echo Start prometheus container
        docker run --detach \
                   --name prometheus \
                   --publish 9090:9090 \
                   --volume $SALT_STATE_TREE/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
                   prom/prometheus -config.file=/etc/prometheus/prometheus.yml \
                                   -storage.local.path=/prometheus \
                                   -storage.local.memory-chunks=10000
}

echo 'docker-run-prometheus-node-exporter() -- Run Prometheus node-exporter container'
docker-run-prometheus-node-exporter() {
        echo Start node-exporter container
        docker run --detach \
                   --publish 9100:9100 \
                   --volume "/proc:/host/proc" \
                   --volume "/sys:/host/sys" \
                   --volume "/:/rootfs" \
                   --net="host" \
                   prom/node-exporter -collector.procfs /host/proc \
                                      -collector.sysfs /host/proc \
                                      -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
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

