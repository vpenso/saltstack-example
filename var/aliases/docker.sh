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

echo 'docker-run-prometheus() -- Run Prometheus service container'
docker-run-prometheus() {
        echo Start prometheus container
        docker run --detach \
                   --name prometheus \
                   --publish 9090:9090 \
                   --volume $SALT_STATE_TREE/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
                   prom/prometheus --config.file=/etc/prometheus/prometheus.yml \
                                   --storage.tsdb.path=/prometheus
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
                   prom/node-exporter --collector.procfs /host/proc \
                                      --collector.sysfs /host/sys \
                                      --collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
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
