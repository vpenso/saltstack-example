PROMETHEUS_VERSION='v2.3.1'
PROMETHEUS_NODE_EXPORTER_VERSION='v0.16.0'

export PROMETHEUS_VERSION \
       PROMETHEUS_NODE_EXPORTER_VERSION

echo 'prometheus-dockerhub-images-to-local-registry() -- Copy Prometheus container images to local registry'
prometheus-dockerhub-images-to-local-registry() {
        
        echo Pull Prometheus container images from DockerHub
        docker pull prom/prometheus:$PROMETHEUS_VERSION
        docker pull prom/node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION
        
        echo Tag and push Prometheus images to local registry
        docker tag prom/prometheus:$PROMETHEUS_VERSION \
                   lxcm01:5000/prometheus:$PROMETHEUS_VERSION
        docker tag prom/node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION \
                   lxcm01:5000/prometheus-node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION 
        docker push lxcm01:5000/prometheus:$PROMETHEUS_VERSION
        docker push lxcm01:5000/prometheus-node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION

}

echo 'prometheus-docker-container() -- Run Prometheus service container'
prometheus-docker-container() {
        echo Start prometheus container
        docker run --detach \
                   --name prometheus \
                   --publish 9090:9090 \
                   --volume $SALT_STATE_TREE/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
                   $DOCKER_LOCAL_REGISTRY/prometheus:$PROMETHEUS_VERSION \
                            --config.file=/etc/prometheus/prometheus.yml \
                            --storage.tsdb.path=/prometheus
}

echo 'prometheus-node-exporter-docker-container() -- Run Prometheus node-exporter container'
prometheus-node-exporter-docker-container() {
        echo Start node-exporter container
        docker run --detach \
                   --publish 9100:9100 \
                   --volume "/proc:/host/proc" \
                   --volume "/sys:/host/sys" \
                   --volume "/:/rootfs" \
                   --net="host" \
                   $DOCKER_LOCAL_REGISTRY/prometheus-node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION \
                            --path.procfs /host/proc \
                            --path.sysfs /host/sys \
                            --collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
}
